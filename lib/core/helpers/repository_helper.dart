import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tenkai/core/errors/failures.dart';

class RepositoryHelper {
  static Future<Either<Failure, T>> execute<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final result = await request();
      return Right(parser(result.data));
    } on DioException catch (e) {
      return Left(e.error as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
