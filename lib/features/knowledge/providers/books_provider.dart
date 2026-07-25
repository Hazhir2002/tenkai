import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

import '../models/book_view.dart';

/// `yyyy-MM-dd` key for a given day (defaults to today).
String bookDateKey([DateTime? day]) {
  final d = day ?? DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$dd';
}

/// Every book, most-recently-updated first.
final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(appDataBaseProvider).bookDao.watchAllBooks();
});

/// All reading sessions across every book (used to compute pace/streak/stats).
final allSessionsProvider = StreamProvider<List<ReadingSession>>((ref) {
  return ref.watch(appDataBaseProvider).bookDao.watchAllSessions();
});

/// Folds books + sessions into computed [BookView]s.
final bookViewsProvider = Provider<AsyncValue<List<BookView>>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final sessionsAsync = ref.watch(allSessionsProvider);

  return booksAsync.whenData((books) {
    final sessions = sessionsAsync.valueOrNull ?? const <ReadingSession>[];
    final byBook = <int, List<ReadingSession>>{};
    for (final s in sessions) {
      byBook.putIfAbsent(s.bookId, () => []).add(s);
    }
    final now = DateTime.now();
    return [
      for (final b in books)
        BookView.compute(b, byBook[b.id] ?? const [], now),
    ];
  });
});

/// A single book's computed view by id.
final bookViewProvider = Provider.family<AsyncValue<BookView?>, int>((ref, id) {
  return ref.watch(bookViewsProvider).whenData(
    (views) => views.where((v) => v.book.id == id).firstOrNull,
  );
});

/// Live reading sessions for one book, newest first.
final sessionsForBookProvider =
    StreamProvider.family<List<ReadingSession>, int>((ref, bookId) {
      return ref.watch(appDataBaseProvider).bookDao.watchSessionsForBook(bookId);
    });

/// Live highlights for one book.
final highlightsForBookProvider =
    StreamProvider.family<List<BookHighlight>, int>((ref, bookId) {
      return ref
          .watch(appDataBaseProvider)
          .bookDao
          .watchHighlightsForBook(bookId);
    });
