import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';
import 'package:tenkai/features/fitness/models/session_exercise_log_model.dart';

final sessionExerciseProvider = FutureProvider.family<SessionExercise, int>((
  ref,
  sessionExerciseId,
) async {
  final db = ref.read(appDataBaseProvider);
  return db.fitnessDao.getSessionExercise(sessionExerciseId);
});

final sessionExerciseLogsProvider =
    FutureProvider.family<List<SessionExerciseLogModel>, int>((
      ref,
      sessionExerciseId,
    ) async {
      final db = ref.read(appDataBaseProvider);
      final result = await db.fitnessDao.getAllSessionExerciseLogs(
        sessionExerciseId,
      );
      return result
          .map((l) => SessionExerciseLogModel.fromSessionExerciseLog(l))
          .toList();
    });
