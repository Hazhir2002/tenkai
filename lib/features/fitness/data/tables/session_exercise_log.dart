import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/fitness/data/tables/session_log.dart';

class SessionExerciseLogs extends Table with TableMixin {
  IntColumn get programSessionLogId =>
      integer().references(SessionLogs, #id, onDelete: KeyAction.cascade)();
  IntColumn get durationSec => integer()();
}
