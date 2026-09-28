import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/program.dart';
import 'tables/program_session.dart';
import 'tables/session_exercise.dart';

part 'fitness_dao.g.dart';

@DriftAccessor(tables: [Programs, ProgramSessions, SessionExercises])
class FitnessDao extends DatabaseAccessor<AppDatabase> with _$FitnessDaoMixin {
  FitnessDao(super.db);

  Future<List<Program>> getAllPrograms() =>
      (select(programs)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<List<ProgramSession>> getAllProgramSessions() => (select(
    programSessions,
  )..orderBy([(t) => OrderingTerm.asc(t.hierarchy)])).get();

  Future<List<SessionExercise>> getAllSessionExercises() => (select(
    sessionExercises,
  )..orderBy([(t) => OrderingTerm.asc(t.hierarchy)])).get();

  Future<Program> createProgram(ProgramsCompanion entry) {
    return transaction(() async {
      return await into(programs).insertReturning(entry);
    });
  }

  Future<ProgramSession> createProgramSession(ProgramSessionsCompanion entry) {
    return transaction(() async {
      return await into(programSessions).insertReturning(entry);
    });
  }

  Future<SessionExercise> createSessionExercise(
    SessionExercisesCompanion entry,
  ) {
    return transaction(() async {
      return await into(sessionExercises).insertReturning(entry);
    });
  }
}
