import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/fitness/data/tables/session_exercise_log.dart';

class ExerciseSetLogs extends Table with TableMixin {
  IntColumn get sessionExerciseLogId => integer().references(
    SessionExerciseLogs,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get setNum => integer()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
}
