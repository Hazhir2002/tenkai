import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/core/services/notification_service.dart';

import '../models/book_enums.dart';

class BookFormState {
  const BookFormState({
    this.original,
    this.title = '',
    this.author = '',
    this.coverImagePath,
    this.totalPages,
    this.currentPage = 0,
    this.status = BookStatus.reading,
    this.deadline,
    this.dailyPageGoal,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.saving = false,
  });

  final Book? original;
  final String title;
  final String author;
  final String? coverImagePath;
  final int? totalPages;
  final int currentPage;
  final BookStatus status;
  final DateTime? deadline;
  final int? dailyPageGoal;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool saving;

  bool get isEditing => original != null;

  bool get isValid {
    if (title.trim().isEmpty) return false;
    final tp = totalPages;
    if (tp == null || tp <= 0) return false;
    if (currentPage < 0 || currentPage > tp) return false;
    return true;
  }

  BookFormState copyWith({
    Object? original = _sentinel,
    String? title,
    String? author,
    Object? coverImagePath = _sentinel,
    Object? totalPages = _sentinel,
    int? currentPage,
    BookStatus? status,
    Object? deadline = _sentinel,
    Object? dailyPageGoal = _sentinel,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? saving,
  }) {
    return BookFormState(
      original: original == _sentinel ? this.original : original as Book?,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImagePath: coverImagePath == _sentinel
          ? this.coverImagePath
          : coverImagePath as String?,
      totalPages: totalPages == _sentinel
          ? this.totalPages
          : totalPages as int?,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      deadline: deadline == _sentinel ? this.deadline : deadline as DateTime?,
      dailyPageGoal: dailyPageGoal == _sentinel
          ? this.dailyPageGoal
          : dailyPageGoal as int?,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      saving: saving ?? this.saving,
    );
  }

  static const _sentinel = Object();
}

class BookFormNotifier extends Notifier<BookFormState> {
  @override
  BookFormState build() => const BookFormState();

  void startCreate() => state = const BookFormState();

  void startEdit(Book book) {
    state = BookFormState(
      original: book,
      title: book.title,
      author: book.author ?? '',
      coverImagePath: book.coverImagePath,
      totalPages: book.totalPages,
      currentPage: book.currentPage,
      status: BookStatus.fromDb(book.status),
      deadline: book.deadline,
      dailyPageGoal: book.dailyPageGoal,
      reminderEnabled: book.reminderEnabled,
      reminderHour: book.reminderHour ?? 20,
      reminderMinute: book.reminderMinute ?? 0,
    );
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setAuthor(String v) => state = state.copyWith(author: v);
  void setCover(String? path) => state = state.copyWith(coverImagePath: path);
  void setTotalPages(int? v) => state = state.copyWith(totalPages: v);
  void setCurrentPage(int v) => state = state.copyWith(currentPage: v);
  void setStatus(BookStatus v) => state = state.copyWith(status: v);
  void setDeadline(DateTime? v) => state = state.copyWith(deadline: v);
  void setDailyGoal(int? v) => state = state.copyWith(dailyPageGoal: v);
  void setReminderEnabled(bool v) =>
      state = state.copyWith(reminderEnabled: v);
  void setReminderTime(int hour, int minute) =>
      state = state.copyWith(reminderHour: hour, reminderMinute: minute);

  /// Persists the draft and (re)schedules the reading reminder. Returns the
  /// book id, or null if invalid.
  Future<int?> save() async {
    if (!state.isValid) return null;
    state = state.copyWith(saving: true);
    final db = ref.read(appDataBaseProvider);
    final notifications = ref.read(notificationServiceProvider);

    final author = state.author.trim().isEmpty ? null : state.author.trim();
    final int bookId;
    if (state.isEditing) {
      final orig = state.original!;
      bookId = orig.id;
      await db.bookDao.updateBook(
        orig.copyWith(
          title: state.title.trim(),
          author: Value(author),
          coverImagePath: Value(state.coverImagePath),
          totalPages: state.totalPages!,
          currentPage: state.currentPage,
          status: state.status.dbValue,
          deadline: Value(state.deadline),
          dailyPageGoal: Value(state.dailyPageGoal),
          reminderEnabled: state.reminderEnabled,
          reminderHour: Value(state.reminderHour),
          reminderMinute: Value(state.reminderMinute),
          startedAt: Value(
            orig.startedAt ??
                (state.status == BookStatus.reading ? DateTime.now() : null),
          ),
        ),
      );
    } else {
      bookId = await db.bookDao.createBook(
        title: state.title.trim(),
        author: author,
        coverImagePath: state.coverImagePath,
        totalPages: state.totalPages!,
        currentPage: state.currentPage,
        status: state.status.dbValue,
        deadline: state.deadline,
        dailyPageGoal: state.dailyPageGoal,
        reminderEnabled: state.reminderEnabled,
        reminderHour: state.reminderHour,
        reminderMinute: state.reminderMinute,
      );
    }

    final book = await db.bookDao.getBook(bookId);
    if (book != null && book.reminderEnabled) {
      await notifications.requestPermissionIfNeeded();
    }
    if (book != null) {
      await notifications.syncBookReminder(book);
    }

    state = state.copyWith(saving: false);
    return bookId;
  }
}

final bookFormProvider =
    NotifierProvider<BookFormNotifier, BookFormState>(BookFormNotifier.new);
