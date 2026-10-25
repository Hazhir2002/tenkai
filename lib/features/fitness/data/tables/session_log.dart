import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/fitness/data/tables/program_session.dart';

class SessionLogs extends Table with TableMixin {
  IntColumn get programSessionId =>
      integer().references(ProgramSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sessionDuration => integer()();
}
