import 'package:tenkai/features/auth/models/user.dart';

/// The payload returned by `/auth/register`, `/auth/login` and `/auth/refresh`:
/// a fresh access/refresh token pair plus the authenticated [User].
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}
