import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';

import 'book.dart';

class BookHighlights extends Table with TableMixin {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get page => integer()();
  TextColumn get quote => text()();
  TextColumn get note => text().nullable()();
}
