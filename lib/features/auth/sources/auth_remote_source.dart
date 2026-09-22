import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/features/auth/models/auth_response.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/params/register_params.dart';

/// Talks to the `/auth` API. Only knows about Dio and JSON — it throws on
/// failure and leaves error-to-[Failure] mapping to the repository.
class AuthRemoteSource {
  final DioClient _dioClient;

  const AuthRemoteSource(this._dioClient);

  Future<AuthResponse> login(LoginParams params) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.login,
      data: params.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> register(RegisterParams params) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.register,
      data: params.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    await _dioClient.dio.post(
      ApiEndpoints.logout,
      data: {'refresh_token': refreshToken},
    );
  }
}

final authRemoteSourceProvider = Provider<AuthRemoteSource>(
  (ref) => AuthRemoteSource(ref.read(dioClientProvider)),
);
