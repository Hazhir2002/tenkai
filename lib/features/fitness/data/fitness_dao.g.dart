// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_dao.dart';

// ignore_for_file: type=lint
mixin _$FitnessDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProgramsTable get programs => attachedDatabase.programs;
  $ProgramSessionsTable get programSessions => attachedDatabase.programSessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  $SessionLogsTable get sessionLogs => attachedDatabase.sessionLogs;
  $SessionExerciseLogsTable get sessionExerciseLogs =>
      attachedDatabase.sessionExerciseLogs;
  $ExerciseSetLogsTable get exerciseSetLogs => attachedDatabase.exerciseSetLogs;
  FitnessDaoManager get managers => FitnessDaoManager(this);
}

class FitnessDaoManager {
  final _$FitnessDaoMixin _db;
  FitnessDaoManager(this._db);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db.attachedDatabase, _db.programs);
  $$ProgramSessionsTableTableManager get programSessions =>
      $$ProgramSessionsTableTableManager(
        _db.attachedDatabase,
        _db.programSessions,
      );
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(
        _db.attachedDatabase,
        _db.sessionExercises,
      );
  $$SessionLogsTableTableManager get sessionLogs =>
      $$SessionLogsTableTableManager(_db.attachedDatabase, _db.sessionLogs);
  $$SessionExerciseLogsTableTableManager get sessionExerciseLogs =>
      $$SessionExerciseLogsTableTableManager(
        _db.attachedDatabase,
        _db.sessionExerciseLogs,
      );
  $$ExerciseSetLogsTableTableManager get exerciseSetLogs =>
      $$ExerciseSetLogsTableTableManager(
        _db.attachedDatabase,
        _db.exerciseSetLogs,
      );
}
