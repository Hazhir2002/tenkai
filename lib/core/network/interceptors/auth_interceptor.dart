import 'package:dio/dio.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/services/storage_service.dart';

/// Attaches the bearer access token to every request and transparently
/// recovers from an expired access token: on a `401` it rotates the token pair
/// via `POST /auth/refresh` and retries the original request once. If the
/// refresh token is itself dead, the session is cleared and [onSessionExpired]
/// notifies the app so it can send the user back to login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, this.onSessionExpired});

  final StorageService storage;
  final void Function()? onSessionExpired;

  /// Marks a request we've already retried, so a second `401` gives up instead
  /// of looping forever.
  static const _retriedKey = 'auth_retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isAuthRoute = request.path.contains('auth/');
    final alreadyRetried = request.extra[_retriedKey] == true;

    // Only attempt recovery for a genuine 401 on a protected, not-yet-retried
    // request. Auth routes (login/refresh) must surface their own 401s.
    if (err.response?.statusCode != 401 || isAuthRoute || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) {
      await _expireSession();
      handler.next(err);
      return;
    }

    // Use a bare Dio (no interceptors) so refreshing can't recurse into itself.
    final bareDio = Dio(BaseOptions(baseUrl: ApiEndpoints.apiUrl));

    late final String newAccess;
    try {
      final refreshResponse = await bareDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final data = refreshResponse.data as Map<String, dynamic>;
      newAccess = data['access_token'] as String;
      await storage.saveTokens(
        accessToken: newAccess,
        refreshToken: data['refresh_token'] as String,
      );
    } catch (_) {
      // The refresh token is expired/revoked — the session is truly over.
      await _expireSession();
      handler.next(err);
      return;
    }

    // Replay the original request once with the rotated access token.
    try {
      request
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra[_retriedKey] = true;
      final retry = await bareDio.fetch(request);
      handler.resolve(retry);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<void> _expireSession() async {
    await storage.deleteAllToken();
    onSessionExpired?.call();
  }
}
