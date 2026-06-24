import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/core/services/storage_service.dart';
import 'package:tenkai/features/auth/models/token_model.dart';
import 'package:tenkai/features/auth/models/user.dart';
import 'package:tenkai/features/auth/params/change_password_params.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/params/reset_password_params.dart';
import 'package:tenkai/features/auth/params/update_profile_params.dart';

class AuthRepository {
  final DioClient _dioClient;
  final StorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<Either<Failure, void>> login(LoginParams params) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: params.toJson(params),
      );
      _storage.saveAccessToken(response.data['accessToken']);
      return Right(null);
    } on DioException catch (e) {
      return Left(e.error as Failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<User> register(RegisterParams registerParams) async {
    throw Exception();
  }

  Future<String> verifyEmail(String token) async {
    throw Exception();
  }

  Future<String> resendVerification(String email) async {
    throw Exception();
  }

  Future<String> logout(String refreshToken) async {
    throw Exception();
  }

  Future<String> logoutAll() async {
    throw Exception();
  }

  Future<String> forgotPassword(String email) async {
    throw Exception();
  }

  Future<String> resetPassword(ResetPasswordParams params) async {
    throw Exception();
  }

  Future<String> changePassword(ChangePasswordParams params) async {
    throw Exception();
  }

  Future<Either<Failure, User>> getMe() async {
    return RepositoryHelper.execute<User>(
      () => _dioClient.dio.get(ApiEndpoints.me),
      parser: User.fromJson,
    );
  }

  Future<User> updateProfile(UpdateProfileParams params) async {
    throw Exception();
  }

  Future<User> uploadAvatar(File file) async {
    throw Exception();
  }

  Future<User> deleteAvatar() async {
    throw Exception();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(dioClientProvider), StorageService()),
);
