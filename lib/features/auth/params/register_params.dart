/// Payload for `POST /auth/register`. All three fields are required.
class RegisterParams {
  final String email;
  final String username;
  final String password;

  const RegisterParams({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
  };
}
