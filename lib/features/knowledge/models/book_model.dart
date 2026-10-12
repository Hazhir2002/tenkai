import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'book_enums.dart';

/// One point on the pace chart: [day] is days since the chart start, [page] the
/// page reached at that time.
class BookChartPoint {
  const BookChartPoint(this.day, this.page);
  final double day;
  final double page;
}

class BookModel extends Book {
  final List<ReadingSession> readingSessions;
  final List<BookHighlight> bookHighlights;

  // ---- Derived values ----
  final double percent; // 0..1
  final int pagesLeft;
  final PaceState paceState;

  /// Where the reader "should" be right now given the target (deadline/goal).
  final int expectedPage;

  /// Pages/day needed to hit the deadline (null if no deadline).
  final double? pagesPerDayNeeded;

  final int streakDays;
  final int pagesThisWeek;
  final double avgPagesPerDay;
  final DateTime? projectedFinish;

  // Chart geometry (x in days since chart start, y in pages 0..totalPages).
  final double spanDays;
  final double todayDay;
  final List<BookChartPoint> actualPoints;

  /// The straight "expected" line endpoints (empty when there's no target).
  final List<BookChartPoint> expectedPoints;

  BookModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.title,
    required super.totalPages,
    required super.currentPage,
    required super.status,
    required super.reminderEnabled,
    super.dailyPageGoal,
    super.author,
    super.startedAt,
    super.finishedAt,
    super.coverImagePath,
    super.deadline,
    super.rating,
    super.reminderHour,
    super.reminderMinute,
    super.review,
    this.readingSessions = const [],
    this.bookHighlights = const [],
    this.percent = 0,
    this.pagesLeft = 0,
    this.paceState = PaceState.noTarget,
    this.expectedPage = 0,
    this.pagesPerDayNeeded,
    this.streakDays = 0,
    this.pagesThisWeek = 0,
    this.avgPagesPerDay = 0,
    this.projectedFinish,
    this.spanDays = 1,
    this.todayDay = 0,
    this.actualPoints = const [],
    this.expectedPoints = const [],
  });

  /// Parsed [status] (the inherited [status] stays the raw DB string).
  BookStatus get bookStatus => BookStatus.fromDb(status);
  bool get hasTarget => deadline != null || (dailyPageGoal ?? 0) > 0;

  factory BookModel.fromBook(
    Book book, {
    List<ReadingSession> readingSessions = const [],
    List<BookHighlight> bookHighlights = const [],
  }) {
    return BookModel(
      id: book.id,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      title: book.title,
      totalPages: book.totalPages,
      currentPage: book.currentPage,
      status: book.status,
      reminderEnabled: book.reminderEnabled,
      reminderHour: book.reminderHour,
      reminderMinute: book.reminderMinute,
      startedAt: book.startedAt,
      finishedAt: book.finishedAt,
      rating: book.rating,
      review: book.review,
      author: book.author,
      dailyPageGoal: book.dailyPageGoal,
      coverImagePath: book.coverImagePath,
      deadline: book.deadline,
      readingSessions: readingSessions,
      bookHighlights: bookHighlights,
    );
  }

  /// Builds a [BookModel] with all derived pace/streak/chart values computed.
  factory BookModel.compute(
    Book book,
    List<ReadingSession> sessions,
    List<BookHighlight> highlights,
    DateTime now,
  ) {
    final total = book.totalPages <= 0 ? 1 : book.totalPages;
    final current = book.currentPage.clamp(0, total);
    final percent = current / total;
    final pagesLeft = (total - current).clamp(0, total);
    final status = BookStatus.fromDb(book.status);

    final start = book.startedAt ?? book.createdAt;
    final elapsedDays = now.difference(start).inMinutes / (60 * 24);
    final elapsed = elapsedDays < 0 ? 0.0 : elapsedDays;

    // Pages read across all tracked sessions, and the page we started tracking.
    final totalRead = sessions.fold<int>(
      0,
      (sum, s) => sum + (s.endPage - s.startPage),
    );
    final startPage = (current - totalRead).clamp(0, total);

    // ---- Pace ----
    var paceState = PaceState.noTarget;
    var expectedPage = current;
    double? pagesPerDayNeeded;

    if (status == BookStatus.finished) {
      paceState = PaceState.finished;
      expectedPage = total;
    } else if (book.deadline != null) {
      final totalDays = book.deadline!.difference(start).inMinutes / (60 * 24);
      final frac = totalDays <= 0 ? 1.0 : (elapsed / totalDays).clamp(0.0, 1.0);
      expectedPage = (total * frac).round();
      final tolerance = (total * 0.02).clamp(1, 10);
      if (current >= expectedPage + tolerance) {
        paceState = PaceState.ahead;
      } else if (current >= expectedPage - tolerance) {
        paceState = PaceState.onTrack;
      } else {
        paceState = PaceState.behind;
      }
      final daysRemaining =
          book.deadline!.difference(now).inMinutes / (60 * 24);
      pagesPerDayNeeded = daysRemaining > 0
          ? pagesLeft / daysRemaining
          : pagesLeft.toDouble();
    } else if ((book.dailyPageGoal ?? 0) > 0) {
      final goal = book.dailyPageGoal!;
      final expectedRead = goal * elapsed;
      expectedPage = (startPage + expectedRead).round().clamp(0, total);
      final tolerance = goal.clamp(1, 20);
      if (current >= expectedPage + tolerance) {
        paceState = PaceState.ahead;
      } else if (current >= expectedPage - tolerance) {
        paceState = PaceState.onTrack;
      } else {
        paceState = PaceState.behind;
      }
    }

    // ---- Streak (consecutive days ending today/yesterday with a session) ----
    String keyOf(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final keys = sessions.map((s) => keyOf(s.createdAt)).toSet();
    var day = DateTime(now.year, now.month, now.day);
    if (!keys.contains(keyOf(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (keys.contains(keyOf(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    // ---- This week + averages ----
    final weekAgo = now.subtract(const Duration(days: 7));
    final pagesThisWeek = sessions
        .where((s) => s.createdAt.isAfter(weekAgo))
        .fold<int>(0, (sum, s) => sum + (s.endPage - s.startPage));
    final avgPagesPerDay = elapsed >= 1
        ? totalRead / elapsed
        : totalRead.toDouble();
    final projectedFinish = (avgPagesPerDay > 0 && pagesLeft > 0)
        ? now.add(Duration(days: (pagesLeft / avgPagesPerDay).ceil()))
        : null;

    // ---- Chart geometry ----
    double dayOffset(DateTime d) => d.difference(start).inMinutes / (60 * 24);
    final targetDay = book.deadline != null
        ? dayOffset(book.deadline!)
        : ((book.dailyPageGoal ?? 0) > 0
              ? (total - startPage) / book.dailyPageGoal!
              : elapsed);
    final spanDays = [targetDay, elapsed, 1.0].reduce((a, b) => a > b ? a : b);

    final actual = <BookChartPoint>[
      BookChartPoint(0, startPage.toDouble()),
      for (final s
          in sessions.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
        BookChartPoint(
          dayOffset(s.createdAt).clamp(0, spanDays),
          s.endPage.toDouble(),
        ),
    ];
    final expected = (book.deadline != null || (book.dailyPageGoal ?? 0) > 0)
        ? [
            BookChartPoint(0, startPage.toDouble()),
            BookChartPoint(targetDay.clamp(0, spanDays), total.toDouble()),
          ]
        : const <BookChartPoint>[];

    return BookModel(
      id: book.id,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      title: book.title,
      totalPages: book.totalPages,
      currentPage: book.currentPage,
      status: book.status,
      reminderEnabled: book.reminderEnabled,
      reminderHour: book.reminderHour,
      reminderMinute: book.reminderMinute,
      startedAt: book.startedAt,
      finishedAt: book.finishedAt,
      rating: book.rating,
      review: book.review,
      author: book.author,
      dailyPageGoal: book.dailyPageGoal,
      coverImagePath: book.coverImagePath,
      deadline: book.deadline,
      readingSessions: sessions,
      bookHighlights: highlights,
      percent: percent,
      pagesLeft: pagesLeft,
      paceState: paceState,
      expectedPage: expectedPage,
      pagesPerDayNeeded: pagesPerDayNeeded,
      streakDays: streak,
      pagesThisWeek: pagesThisWeek,
      avgPagesPerDay: avgPagesPerDay,
      projectedFinish: projectedFinish,
      spanDays: spanDays,
      todayDay: elapsed.clamp(0, spanDays),
      actualPoints: actual,
      expectedPoints: expected,
    );
  }

  @override
  BookModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> coverImagePath = const Value.absent(),
    int? totalPages,
    int? currentPage,
    Value<DateTime?> deadline = const Value.absent(),
    Value<int?> dailyPageGoal = const Value.absent(),
    bool? reminderEnabled,
    Value<int?> reminderHour = const Value.absent(),
    Value<int?> reminderMinute = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    String? status,
    List<ReadingSession>? readingSessions,
    List<BookHighlight>? bookHighlights,
  }) {
    return BookModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      readingSessions: readingSessions ?? this.readingSessions,
      bookHighlights: bookHighlights ?? this.bookHighlights,
      dailyPageGoal: dailyPageGoal.value ?? this.dailyPageGoal,
      review: review.value ?? this.review,
      rating: rating.value ?? this.rating,
      reminderHour: reminderHour.value ?? this.reminderHour,
      reminderMinute: reminderMinute.value ?? this.reminderMinute,
      coverImagePath: coverImagePath.value ?? this.coverImagePath,
      author: author.value ?? this.author,
      deadline: deadline.value ?? this.deadline,
      startedAt: startedAt.value ?? this.startedAt,
      finishedAt: finishedAt.value ?? this.finishedAt,
      // Derived values carried over as-is.
      percent: percent,
      pagesLeft: pagesLeft,
      paceState: paceState,
      expectedPage: expectedPage,
      pagesPerDayNeeded: pagesPerDayNeeded,
      streakDays: streakDays,
      pagesThisWeek: pagesThisWeek,
      avgPagesPerDay: avgPagesPerDay,
      projectedFinish: projectedFinish,
      spanDays: spanDays,
      todayDay: todayDay,
      actualPoints: actualPoints,
      expectedPoints: expectedPoints,
    );
  }
}
