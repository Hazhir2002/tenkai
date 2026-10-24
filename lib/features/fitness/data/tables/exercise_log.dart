import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/fitness/data/tables/session_exercise.dart';

class ExerciseLogs extends Table with TableMixin {
  IntColumn get sessionExerciseId => integer().references(
    SessionExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get setNum => integer()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
}
