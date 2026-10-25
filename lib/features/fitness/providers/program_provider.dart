import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

final sessionExerciseProvider = FutureProvider.family<SessionExercise, int>((
  ref,
  sessionExerciseId,
) async {
  final db = ref.read(appDataBaseProvider);
  return db.fitnessDao.getSessionExercise(sessionExerciseId);
});
