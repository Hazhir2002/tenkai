import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/interceptors/auth_interceptor.dart';
import 'package:tenkai/core/network/interceptors/error_decoder_interceptor.dart';
import 'package:tenkai/core/services/storage_service.dart';
import 'package:tenkai/features/auth/providers/auth_provider.dart';

class DioClient {
  late final Dio _dio;

  DioClient({required StorageService storage, void Function()? onSessionExpired}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      ErrorDecoderInterceptor(),
      AuthInterceptor(storage: storage, onSessionExpired: onSessionExpired),
      // Body logging can leak passwords/tokens — keep it to debug builds only.
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(
    storage: ref.read(storageServiceProvider),
    // Lazily reached only when a refresh finally fails, so this never forces
    // authProvider to build while DioClient itself is being constructed.
    onSessionExpired: () => ref.read(authProvider.notifier).markSessionExpired(),
  ),
);
