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

  Future<List<Book>> getAllBooks() =>
      (select(books)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<Book?> getBook(int id) =>
      (select(books)..where((tbl) => tbl.id.equals(id))).getSingle();

  Future<Book> createBook(BooksCompanion entry) {
    return transaction(() async {
      return await into(books).insertReturning(entry);
    });
  }

  Future<Book> updateBook(BooksCompanion entry) {
    return transaction(() async {
      final updatedBooks = await (update(
        books,
      )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);

      return updatedBooks.first;
    });
  }

  Future<int> deleteBook(int id) {
    return transaction(() async {
      return (delete(books)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<ReadingSession>> getAllReadingSessions(int bookId) =>
      (select(readingSessions)
            ..where((tbl) => tbl.bookId.equals(bookId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<ReadingSession> createReadingSession(ReadingSessionsCompanion entry) {
    return transaction(() async {
      return await into(readingSessions).insertReturning(entry);
    });
  }

  Future<ReadingSession> updateReadingSession(ReadingSessionsCompanion entry) {
    return transaction(() async {
      final updatedReadingSessions = await (update(
        readingSessions,
      )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);

      return updatedReadingSessions.first;
    });
  }

  Future<int> deleteReadingSession(int id) {
    return transaction(() async {
      return (delete(readingSessions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<BookHighlight>> getAllBookHighlights(int bookId) =>
      (select(bookHighlights)
            ..where((tbl) => tbl.bookId.equals(bookId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<BookHighlight> createBookHighlight(BookHighlightsCompanion entry) {
    return transaction(() async {
      return await into(bookHighlights).insertReturning(entry);
    });
  }

  Future<BookHighlight> updateBookHighlight(BookHighlightsCompanion entry) {
    return transaction(() async {
      final updatedBookHighlights = await (update(
        bookHighlights,
      )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);

      return updatedBookHighlights.first;
    });
  }

  Future<int> deleteBookHighlight(int id) {
    return transaction(() async {
      return (delete(bookHighlights)..where((t) => t.id.equals(id))).go();
    });
  }

  // Future<void> finishBook(int id, {int? rating, String? review}) async {
  //   final book = await getBook(id);
  //   if (book == null) return;
  //   // await updateBook(
  //   //   book.copyWith(
  //   //     status: 'finished',
  //   //     currentPage: book.totalPages,
  //   //     rating: Value(rating),
  //   //     review: Value(review),
  //   //     finishedAt: Value(DateTime.now()),
  //   //   ),
  //   // );
  // }

  // Stream<List<BookHighlight>> watchHighlightsForBook(int bookId) =>
  //     (select(bookHighlights)
  //           ..where((t) => t.bookId.equals(bookId))
  //           ..orderBy([(t) => OrderingTerm.asc(t.page)]))
  //         .watch();

  // Future<int> addHighlight({
  //   required int bookId,
  //   required int page,
  //   required String quote,
  //   String? note,
  // }) {
  //   return into(bookHighlights).insert(
  //     BookHighlightsCompanion.insert(
  //       bookId: bookId,
  //       page: page,
  //       quote: quote,
  //       note: Value(note),
  //     ),
  //   );
  // }

  // Future<int> deleteHighlight(int id) =>
  //     (delete(bookHighlights)..where((t) => t.id.equals(id))).go();
}
