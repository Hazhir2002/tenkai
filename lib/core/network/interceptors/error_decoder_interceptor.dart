import 'package:dio/dio.dart';
import 'package:tenkai/core/errors/failures.dart';

class ErrorDecoderInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: NetworkFailure(),
        ),
      );
      return;
    }

    final data = response.data;

    String message = 'Unknown error';

    if (data is Map<String, dynamic>) {
      message = data['error'] ?? message;
    }

    late Failure failure;

    switch (response.statusCode) {
      case 400:
        failure = ValidationFailure(message);
        break;
      case 401:
        failure = UnauthorizedFailure(message);
        break;
      case 500:
        failure = ServerFailure();
        break;
      default:
        failure = UnknownFailure(message);
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: failure,
        response: response,
      ),
    );
  }
}
