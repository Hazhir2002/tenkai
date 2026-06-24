import 'package:dio/dio.dart';
import 'package:tenkai/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storage;
  // final AuthApi authApi;

  const AuthInterceptor({required this.storage});

  // bool _isRefreshing = false;
  // final List<RequestOptions> _queue = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();

    print('injecting the authorization header...');
    print(token);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) async {
  //   final status = err.response?.statusCode;

  //   if (status != 401) {
  //     handler.next(err);
  //     return;
  //   }

  //   final request = err.requestOptions;

  //   _queue.add(request);

  //   if (_isRefreshing) return;

  //   _isRefreshing = true;

  //   try {
  //     final refreshToken = await storage.getRefreshToken();
  //     if (refreshToken == null) throw Exception("No refresh token");

  //     final result = await authApi.refresh(refreshToken);

  //     final newAccess = result['accessToken'];
  //     final newRefresh = result['refreshToken'];

  //     await storage.saveTokens(
  //       accessToken: newAccess,
  //       refreshToken: newRefresh,
  //     );

  //     for (final req in _queue) {
  //       final token = newAccess;
  //       req.headers['Authorization'] = 'Bearer $token';
  //     }

  //     final retryResponses = await Future.wait(
  //       _queue.map((req) => err.requestOptions.copyWith()),
  //     );

  //     _queue.clear();
  //     _isRefreshing = false;

  //     handler.resolve(err.response!);
  //   } catch (e) {
  //     _queue.clear();
  //     _isRefreshing = false;
  //     await storage.clear();
  //     handler.next(err);
  //   }
  // }
}
