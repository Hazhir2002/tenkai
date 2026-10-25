import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/program.dart';
import 'tables/program_session.dart';
import 'tables/session_exercise.dart';
import 'tables/session_log.dart';
import 'tables/session_exercise_log.dart';
import 'tables/exercise_set_log.dart';

part 'fitness_dao.g.dart';

@DriftAccessor(
  tables: [
    Programs,
    ProgramSessions,
    SessionExercises,
    SessionLogs,
    SessionExerciseLogs,
    ExerciseSetLogs,
  ],
)
class FitnessDao extends DatabaseAccessor<AppDatabase> with _$FitnessDaoMixin {
  FitnessDao(super.db);

  Future<List<Program>> getAllPrograms() =>
      (select(programs)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<List<ProgramSession>> getAllProgramSessions(int programId) =>
      (select(programSessions)
            ..where((tbl) => tbl.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm.asc(t.hierarchy)]))
          .get();

  Future<List<SessionExercise>> getAllSessionExercises(int programSessionId) =>
      (select(sessionExercises)
            ..where((tbl) => tbl.sessionId.equals(programSessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.hierarchy)]))
          .get();

  Future<SessionExercise> getSessionExercise(int sessionExerciseId) => (select(
    sessionExercises,
  )..where((tbl) => tbl.id.equals(sessionExerciseId))).getSingle();

  Future<Program> createProgram(ProgramsCompanion entry) {
    return transaction(() async {
      return await into(programs).insertReturning(entry);
    });
  }

  Future<int> deleteProgram(int id) {
    return transaction(() async {
      return (delete(programs)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<ProgramSession> createProgramSession(ProgramSessionsCompanion entry) {
    return transaction(() async {
      return await into(programSessions).insertReturning(entry);
    });
  }

  Future<int> deleteProgramSession(int id) {
    return transaction(() async {
      return (delete(programSessions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<SessionExercise> createSessionExercise(
    SessionExercisesCompanion entry,
  ) {
    return transaction(() async {
      return await into(sessionExercises).insertReturning(entry);
    });
  }

  Future<int> deleteSessionExercise(int id) {
    return transaction(() async {
      return (delete(sessionExercises)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<SessionLog>> getAllSessionLogs(int programSessionId) => (select(
    sessionLogs,
  )..where((t) => t.programSessionId.equals(programSessionId))).get();

  Future<SessionLog> getSessionLog(int id) =>
      (select(sessionLogs)..where((t) => t.id.equals(id))).getSingle();

  Future<SessionLog> createSessionLog(SessionLogsCompanion entry) =>
      transaction(() async {
        return (into(sessionLogs).insertReturning(entry));
      });

  Future<SessionLog> updateSessionLog(SessionLogsCompanion entry) =>
      transaction(() async {
        final updatedSessionLog = await (update(
          sessionLogs,
        )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);
        return updatedSessionLog.first;
      });

  Future<List<SessionExerciseLog>> getAllSessionExerciseLogs(
    int programSessionLogId,
  ) => (select(
    sessionExerciseLogs,
  )..where((t) => t.programSessionLogId.equals(programSessionLogId))).get();

  Future<SessionExerciseLog> createSessionExerciseLog(
    SessionExerciseLogsCompanion entry,
  ) => transaction(() async {
    return (into(sessionExerciseLogs).insertReturning(entry));
  });

  Future<SessionExerciseLog> updateSessionExerciseLog(
    SessionExerciseLogsCompanion entry,
  ) => transaction(() async {
    final updatedSessionExerciseLog = await (update(
      sessionExerciseLogs,
    )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);
    return updatedSessionExerciseLog.first;
  });

  Future<List<ExerciseSetLog>> getAllExerciseSetLogs(
    int sessionExerciseLogId,
  ) => (select(
    exerciseSetLogs,
  )..where((t) => t.sessionExerciseLogId.equals(sessionExerciseLogId))).get();

  Future<ExerciseSetLog> createExerciseSetLog(ExerciseSetLogsCompanion entry) =>
      transaction(() async {
        return (into(exerciseSetLogs).insertReturning(entry));
      });

  Future<ExerciseSetLog> updateExerciseSetLog(ExerciseSetLogsCompanion entry) =>
      transaction(() async {
        final updatedExerciseSetLog = await (update(
          exerciseSetLogs,
        )..where((b) => b.id.equals(entry.id.value))).writeReturning(entry);
        return updatedExerciseSetLog.first;
      });
}
