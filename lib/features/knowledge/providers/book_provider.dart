import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/features/knowledge/models/book_model.dart';

class BookState {
  final List<BookModel> books;
  final bool isLoading;
  final String? error;

  const BookState({this.books = const [], this.error, this.isLoading = false});

  BookState copyWith({
    List<BookModel>? books,
    String? error,
    bool? isLoading,
  }) => BookState(
    books: books ?? this.books,
    error: error ?? this.error,
    isLoading: isLoading ?? this.isLoading,
  );
}

class BookNotifier extends Notifier<BookState> {
  late AppDatabase db;

  @override
  BookState build() {
    db = ref.read(appDataBaseProvider);
    Future.microtask(() => listBooks());
    return const BookState();
  }

  Future<void> listBooks() async {
    state = state.copyWith(isLoading: true, error: null, books: null);
    final result = await db.bookDao.getAllBooks();
    List<BookModel> bookModels = result
        .map((p) => BookModel.fromBook(p))
        .toList();
    state = state.copyWith(isLoading: false, error: null, books: bookModels);
  }

  Future<void> createBook(BooksCompanion entry) async {
    final result = await db.bookDao.createBook(entry);
    state = state.copyWith(books: [...state.books, BookModel.fromBook(result)]);
  }

  Future<void> updateBook(BooksCompanion entry) async {
    final result = await db.bookDao.updateBook(entry);
    final updatedBook = BookModel.fromBook(result);

    state = state.copyWith(
      books: state.books.map((book) {
        return book.id == updatedBook.id ? updatedBook : book;
      }).toList(),
    );
  }

  Future<void> deleteBook(int bookId) async {
    final result = await db.bookDao.deleteBook(bookId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete book');
      return;
    }
    state = state.copyWith(
      books: state.books.where((book) => book.id != bookId).toList(),
    );
  }

  Future<void> listReadingSessions(int bookId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessions = await db.bookDao.getAllReadingSessions(bookId);

      // Map through the list and update only the target program
      final updatedBooks = state.books.map((book) {
        if (book.id == bookId) {
          List<ReadingSession> readingSessions = sessions
              .map((p) => p)
              .toList();
          return book.copyWith(readingSessions: readingSessions);
        }
        return book;
      }).toList();

      state = state.copyWith(isLoading: false, books: updatedBooks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addReadingSession(ReadingSessionsCompanion entry) async {
    final result = await db.bookDao.createReadingSession(entry);
    final updatedBooks = state.books.map((book) {
      if (book.id == entry.bookId.value) {
        return book.copyWith(
          readingSessions: [...book.readingSessions, result],
        );
      }
      return book;
    }).toList();
    state = state.copyWith(books: updatedBooks);
  }

  Future<void> updateReadingSession(ReadingSessionsCompanion entry) async {
    final result = await db.bookDao.updateReadingSession(entry);

    state = state.copyWith(
      books: state.books.map((book) {
        if (book.id != entry.bookId.value) {
          return book;
        }
        final updatedReadingSessions = book.readingSessions.map((
          readingSession,
        ) {
          if (readingSession.id == entry.id.value) {
            return result;
          }
          return readingSession;
        }).toList();
        return book.copyWith(readingSessions: updatedReadingSessions);
      }).toList(),
    );
  }

  Future<void> deleteReadingSession(int bookId, int readingSessionId) async {
    final result = await db.bookDao.deleteReadingSession(bookId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete reading session');
      return;
    }
    final updatedBooks = state.books.map((book) {
      if (book.id == bookId) {
        return book.copyWith(
          readingSessions: book.readingSessions
              .where((session) => session.id != readingSessionId)
              .toList(),
        );
      }
      return book;
    }).toList();
    state = state.copyWith(books: updatedBooks);
  }

  Future<void> listBookHighlights(int bookId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final highlights = await db.bookDao.getAllBookHighlights(bookId);

      final updatedBooks = state.books.map((book) {
        if (book.id == bookId) {
          List<BookHighlight> bookHighlights = highlights
              .map((p) => p)
              .toList();
          return book.copyWith(bookHighlights: bookHighlights);
        }
        return book;
      }).toList();

      state = state.copyWith(isLoading: false, books: updatedBooks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBookHighlight(BookHighlightsCompanion entry) async {
    final result = await db.bookDao.createBookHighlight(entry);
    final updatedBooks = state.books.map((book) {
      if (book.id == entry.bookId.value) {
        return book.copyWith(bookHighlights: [...book.bookHighlights, result]);
      }
      return book;
    }).toList();
    state = state.copyWith(books: updatedBooks);
  }

  Future<void> updateBookHighlight(BookHighlightsCompanion entry) async {
    final result = await db.bookDao.updateBookHighlight(entry);

    state = state.copyWith(
      books: state.books.map((book) {
        if (book.id != entry.bookId.value) {
          return book;
        }
        final updatedBookHighlights = book.bookHighlights.map((bookHighlight) {
          if (bookHighlight.id == entry.id.value) {
            return result;
          }
          return bookHighlight;
        }).toList();
        return book.copyWith(bookHighlights: updatedBookHighlights);
      }).toList(),
    );
  }

  Future<void> deleteBookHighlight(int bookId, int bookHighlightId) async {
    final result = await db.bookDao.deleteBookHighlight(bookId);
    if (result == 0) {
      state = state.copyWith(error: 'Failed to delete book highlight');
      return;
    }
    final updatedBooks = state.books.map((book) {
      if (book.id == bookId) {
        return book.copyWith(
          bookHighlights: book.bookHighlights
              .where((session) => session.id != bookHighlightId)
              .toList(),
        );
      }
      return book;
    }).toList();
    state = state.copyWith(books: updatedBooks);
  }
}

final bookProvider = NotifierProvider<BookNotifier, BookState>(
  BookNotifier.new,
);
