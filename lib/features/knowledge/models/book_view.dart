import 'package:tenkai/core/database.dart';

import 'book_enums.dart';

/// One point on the pace chart: [day] is days since the chart start, [page] the
/// page reached at that time.
class BookChartPoint {
  const BookChartPoint(this.day, this.page);
  final double day;
  final double page;
}

/// An immutable, UI-ready projection of a [Book]: the raw row plus its reading
/// sessions and all the derived pace/streak/chart values the UI needs.
class BookView {
  const BookView({
    required this.book,
    required this.sessions,
    required this.percent,
    required this.pagesLeft,
    required this.paceState,
    required this.expectedPage,
    required this.pagesPerDayNeeded,
    required this.streakDays,
    required this.pagesThisWeek,
    required this.avgPagesPerDay,
    required this.projectedFinish,
    required this.spanDays,
    required this.todayDay,
    required this.actualPoints,
    required this.expectedPoints,
  });

  final Book book;
  final List<ReadingSession> sessions;

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

  BookStatus get status => BookStatus.fromDb(book.status);
  bool get hasTarget => book.deadline != null || (book.dailyPageGoal ?? 0) > 0;

  static BookView compute(
    Book book,
    List<ReadingSession> sessions,
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
    final keys = sessions.map((s) => s.dateKey).toSet();
    String keyOf(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
    final avgPagesPerDay = elapsed >= 1 ? totalRead / elapsed : totalRead.toDouble();
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
        BookChartPoint(dayOffset(s.createdAt).clamp(0, spanDays), s.endPage.toDouble()),
    ];
    final expected = book.deadline != null
        ? [
            BookChartPoint(0, startPage.toDouble()),
            BookChartPoint(targetDay.clamp(0, spanDays), total.toDouble()),
          ]
        : ((book.dailyPageGoal ?? 0) > 0
              ? [
                  BookChartPoint(0, startPage.toDouble()),
                  BookChartPoint(
                    targetDay.clamp(0, spanDays),
                    total.toDouble(),
                  ),
                ]
              : const <BookChartPoint>[]);

    return BookView(
      book: book,
      sessions: sessions,
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
}
