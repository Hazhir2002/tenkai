import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tenkai/core/errors/failures.dart';

class ErrorDecoderInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
      // Transport/connection-level failure: there is no HTTP response (DNS,
      // routing, timeout, refused, OS-level block…). Preserve the original
      // DioException type and the underlying OS error (the SocketException +
      // errno) so the real cause is visible instead of a blank "unknown".
      if (kDebugMode) {
        debugPrint(
          '[Network] transport error → type=${err.type} '
          'error=${err.error} (${err.error.runtimeType}) '
          'message=${err.message}',
        );
      }
      final detail =
          err.error?.toString() ?? err.message ?? 'No internet connection.';
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          stackTrace: err.stackTrace,
          message: err.message,
          error: NetworkFailure(detail),
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
