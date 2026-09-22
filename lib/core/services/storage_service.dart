import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Secure, encrypted storage for the JWT access + refresh token pair, plus the
/// persisted UI theme-mode preference.
class StorageService {
  static const _accessTokenKey = 'access-token';
  static const _refreshTokenKey = 'refresh-token';
  static const _themeModeKey = 'theme-mode';

  final FlutterSecureStorage _storage;

  StorageService() : _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> deleteAccessToken() => _storage.delete(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<void> deleteRefreshToken() => _storage.delete(key: _refreshTokenKey);

  /// Persists a freshly issued token pair (from login/register/refresh).
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// Clears the whole session — used on logout and on unrecoverable auth loss.
  Future<void> deleteAllToken() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }

  // ── Theme mode ──

  /// The persisted theme-mode preference, defaulting to [ThemeMode.system].
  Future<ThemeMode> getThemeMode() async {
    final raw = await _storage.read(key: _themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _storage.write(key: _themeModeKey, value: mode.name);
}

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);
