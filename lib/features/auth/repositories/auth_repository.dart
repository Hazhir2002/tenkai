import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/dio_client.dart';
import 'package:tenkai/core/services/storage_service.dart';
import 'package:tenkai/features/auth/models/token_model.dart';
import 'package:tenkai/features/auth/models/user_model.dart';
import 'package:tenkai/features/auth/params/login_params.dart';

class AuthRepository {
  final DioClient _dioClient;
  final StorageService _storageService;

  const AuthRepository(this._dioClient, this._storageService);

  Future<Either<Failure, void>> login(LoginParams params) async {
    final result = await RepositoryHelper.execute<TokenModel>(
      () => _dioClient.dio.post(ApiEndpoints.login, data: params.toJson()),
      parser: TokenModel.fromJson,
    );

    if (result.isLeft()) {
      return Left(result.swap().getOrElse(() => throw Exception()));
    }

    final token = result.getOrElse(() => throw Exception());

    await _storageService.saveAccessToken(token.accessToken);
    await _storageService.saveRefreshToken(token.refreshToken);

    return const Right(null);
  }

  Future<Either<Failure, UserModel>> authenticateUser() =>
      RepositoryHelper.execute(
        () => _dioClient.dio.get(ApiEndpoints.me),
        parser: UserModel.fromJson,
      );
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.read(dioClientProvider),
    ref.read(storageServiceProvider),
  ),
);
