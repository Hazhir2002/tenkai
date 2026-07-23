import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/features/gym_tracker/models/exercise.dart';

class ExerciseRepository {
  final DioClient _dioClient;

  const ExerciseRepository(this._dioClient);

  Future<Either<Failure, List<Exercise>>> searchExercises() {
    return RepositoryHelper.executeList<Exercise>(
      () => _dioClient.dio.get(ApiEndpoints.searchExercises),
      itemParser: Exercise.fromJson,
    );
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.read(dioClientProvider)),
);
