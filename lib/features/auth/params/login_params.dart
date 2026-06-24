class LoginParams {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});

  Map<String, String> toJson(LoginParams params) => {
    'username': params.username,
    'password': params.password,
  };
}
