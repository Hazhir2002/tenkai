// repository_helper.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tenkai/core/errors/failures.dart';

class RepositoryHelper {
  /// For endpoints returning a single object.
  static Future<Either<Failure, T>> execute<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final result = await request();
      final data = result.data;
      if (data is! Map<String, dynamic>) {
        return Left(
          UnknownFailure(
            'Expected an object response but got ${data.runtimeType}',
          ),
        );
      }

      return Right(parser(data));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// For endpoints returning a list of objects.
  static Future<Either<Failure, List<T>>> executeList<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(Map<String, dynamic> json) itemParser,
  }) async {
    try {
      final result = await request();
      final data = result.data;
      if (data is! List) {
        return Left(
          UnknownFailure(
            'Expected a list response but got ${data.runtimeType}',
          ),
        );
      }
      final items = data
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  static Future<Either<Failure, T>> executeFromSource<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  static Failure _mapDioException(DioException e) {
    // If an interceptor already attached a typed Failure, trust it.
    if (e.error is Failure) return e.error as Failure;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Request timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');
      case DioExceptionType.badResponse:
        final message = _extractServerMessage(e.response?.data);
        return ServerFailure(message ?? 'Server error');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return UnknownFailure(e.message ?? 'Unknown error');
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}
