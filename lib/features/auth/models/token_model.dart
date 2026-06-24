class TokenModel {
  final String accessToken;

  const TokenModel({required this.accessToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(accessToken: json['accessToken']);
  }
}
