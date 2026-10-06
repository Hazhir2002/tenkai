import 'package:drift/drift.dart';

import 'package:tenkai/core/table_mixin.dart';
import 'program_session.dart';

class SessionExercises extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 64)();
  IntColumn get sessionId =>
      integer().references(ProgramSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sets => integer().withDefault(const Constant(1))();
  IntColumn get repsStart => integer().nullable()();
  IntColumn get repsEnd => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  IntColumn get hierarchy => integer()();
}
