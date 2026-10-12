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

/// Live highlights for one book.
final highlightsForBookProvider =
    StreamProvider.family<List<BookHighlight>, int>((ref, bookId) {
      return ref
          .watch(appDataBaseProvider)
          .bookDao
          .watchHighlightsForBook(bookId);
    });
