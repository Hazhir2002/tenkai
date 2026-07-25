import 'package:drift/drift.dart';

import 'book.dart';

/// A saved quote / highlight from a book, with the page it came from.
class BookHighlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get page => integer()();
  TextColumn get quote => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
