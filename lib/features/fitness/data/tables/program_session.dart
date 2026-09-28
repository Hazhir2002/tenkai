import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'program.dart';

class ProgramSessions extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 64)();
  IntColumn get programId =>
      integer().references(Programs, #id, onDelete: KeyAction.cascade)();
  IntColumn get hierarchy => integer().unique()();
}
