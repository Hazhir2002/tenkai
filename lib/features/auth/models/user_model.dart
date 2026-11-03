import 'package:tenkai/features/auth/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
