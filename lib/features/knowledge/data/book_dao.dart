import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/book.dart';
import 'tables/book_highlight.dart';
import 'tables/reading_session.dart';

part 'book_dao.g.dart';

/// Data access for the book tracker (knowledge feature).
@DriftAccessor(tables: [Books, ReadingSessions, BookHighlights])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  // ---- Books ----

  Stream<List<Book>> watchAllBooks() => (select(books)
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch();

  Stream<Book?> watchBook(int id) =>
      (select(books)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<Book?> getBook(int id) =>
      (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> createBook({
    required String title,
    String? author,
    String? coverImagePath,
    required int totalPages,
    int currentPage = 0,
    String status = 'reading',
    DateTime? deadline,
    int? dailyPageGoal,
    bool reminderEnabled = false,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return into(books).insert(
      BooksCompanion.insert(
        title: title,
        author: Value(author),
        coverImagePath: Value(coverImagePath),
        totalPages: totalPages,
        currentPage: Value(currentPage),
        status: Value(status),
        deadline: Value(deadline),
        dailyPageGoal: Value(dailyPageGoal),
        reminderEnabled: Value(reminderEnabled),
        reminderHour: Value(reminderHour),
        reminderMinute: Value(reminderMinute),
        startedAt: Value(status == 'reading' ? DateTime.now() : null),
      ),
    );
  }

  Future<void> updateBook(Book book) =>
      update(books).replace(book.copyWith(updatedAt: DateTime.now()));

  Future<int> deleteBook(int id) =>
      (delete(books)..where((t) => t.id.equals(id))).go();

  /// Marks a book finished with an optional rating/review.
  Future<void> finishBook(int id, {int? rating, String? review}) async {
    final book = await getBook(id);
    if (book == null) return;
    await updateBook(
      book.copyWith(
        status: 'finished',
        currentPage: book.totalPages,
        rating: Value(rating),
        review: Value(review),
        finishedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---- Reading sessions ----

  Stream<List<ReadingSession>> watchSessionsForBook(int bookId) =>
      (select(readingSessions)
            ..where((t) => t.bookId.equals(bookId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<ReadingSession>> watchAllSessions() =>
      select(readingSessions).watch();

  /// Records a progress update and advances the book's [currentPage] in one
  /// transaction. Marks the book finished when it reaches the last page.
  Future<int> addSession({
    required int bookId,
    required int startPage,
    required int endPage,
    String? summary,
    String source = 'typed',
    required String dateKey,
  }) {
    return transaction(() async {
      final sessionId = await into(readingSessions).insert(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          startPage: startPage,
          endPage: endPage,
          summary: Value(summary),
          source: Value(source),
          dateKey: dateKey,
        ),
      );
      final book = await getBook(bookId);
      if (book != null) {
        final finished = endPage >= book.totalPages;
        await update(books).replace(
          book.copyWith(
            currentPage: endPage.clamp(0, book.totalPages),
            status: finished ? 'finished' : book.status,
            finishedAt: finished
                ? Value(book.finishedAt ?? DateTime.now())
                : Value(book.finishedAt),
            updatedAt: DateTime.now(),
          ),
        );
      }
      return sessionId;
    });
  }

  Future<int> deleteSession(int id) =>
      (delete(readingSessions)..where((t) => t.id.equals(id))).go();

  // ---- Highlights ----

  Stream<List<BookHighlight>> watchHighlightsForBook(int bookId) =>
      (select(bookHighlights)
            ..where((t) => t.bookId.equals(bookId))
            ..orderBy([(t) => OrderingTerm.asc(t.page)]))
          .watch();

  Future<int> addHighlight({
    required int bookId,
    required int page,
    required String quote,
    String? note,
  }) {
    return into(bookHighlights).insert(
      BookHighlightsCompanion.insert(
        bookId: bookId,
        page: page,
        quote: quote,
        note: Value(note),
      ),
    );
  }

  Future<int> deleteHighlight(int id) =>
      (delete(bookHighlights)..where((t) => t.id.equals(id))).go();
}
