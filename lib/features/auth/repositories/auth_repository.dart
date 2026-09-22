import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/errors/failures.dart';
import 'package:tenkai/core/helpers/repository_helper.dart';
import 'package:tenkai/core/services/storage_service.dart';
import 'package:tenkai/features/auth/models/auth_response.dart';
import 'package:tenkai/features/auth/models/user.dart';
import 'package:tenkai/features/auth/params/login_params.dart';
import 'package:tenkai/features/auth/params/register_params.dart';
import 'package:tenkai/features/auth/sources/auth_remote_source.dart';

/// Coordinates authentication: talks to [AuthRemoteSource] and owns the local
/// token pair in [StorageService]. Every method returns `Either<Failure, _>`.
class AuthRepository {
  final AuthRemoteSource _remoteSource;
  final StorageService _storage;

  const AuthRepository(this._remoteSource, this._storage);

  Future<Either<Failure, User>> login(LoginParams params) =>
      RepositoryHelper.executeFromSource(() async {
        final auth = await _remoteSource.login(params);
        await _persist(auth);
        return auth.user;
      });

  Future<Either<Failure, User>> register(RegisterParams params) =>
      RepositoryHelper.executeFromSource(() async {
        final auth = await _remoteSource.register(params);
        await _persist(auth);
        return auth.user;
      });

  /// Restores a session on launch by exchanging the stored refresh token for a
  /// fresh pair (there is no `/users/me` endpoint). Returns [UnauthorizedFailure]
  /// when there is no stored session to restore.
  Future<Either<Failure, User>> restoreSession() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return const Left(UnauthorizedFailure('No active session'));
    }
    return RepositoryHelper.executeFromSource(() async {
      final auth = await _remoteSource.refresh(refreshToken);
      await _persist(auth);
      return auth.user;
    });
  }

  /// Revokes the refresh token server-side and clears local tokens. The local
  /// clear happens regardless of the network outcome so the user is always
  /// logged out on their device.
  Future<Either<Failure, Unit>> logout() =>
      RepositoryHelper.executeFromSource(() async {
        final refreshToken = await _storage.getRefreshToken();
        try {
          if (refreshToken != null) {
            await _remoteSource.logout(refreshToken);
          }
        } finally {
          await _storage.deleteAllToken();
        }
        return unit;
      });

  Future<void> _persist(AuthResponse auth) => _storage.saveTokens(
    accessToken: auth.accessToken,
    refreshToken: auth.refreshToken,
  );
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.read(authRemoteSourceProvider),
    ref.read(storageServiceProvider),
  ),
);
