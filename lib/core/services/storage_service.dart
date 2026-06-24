import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StorageService {
  late FlutterSecureStorage _storage;

  StorageService() {
    _storage = FlutterSecureStorage();
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access-token');
  }

  Future<void> deleteAllToken() async {
    await deleteAccessToken();
    // await deleteRefreshToken();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access-token');
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access-token', value: token);
  }

  // Future<void> deleteRefreshToken() async {
  //   await _storage.delete(key: _refreshTokenKey);
  // }

  // Future<String?> getRefreshToken() async {
  //   return await _storage.read(key: _refreshTokenKey);
  // }

  // Future<void> saveRefreshToken(String token) async {
  //   await _storage.write(key: _refreshTokenKey, value: token);
  // }
}

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);
