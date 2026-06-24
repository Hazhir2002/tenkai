import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/network/api_endpoints.dart';
import 'package:tenkai/core/network/interceptors/auth_interceptor.dart';
import 'package:tenkai/core/network/interceptors/error_decoder_interceptor.dart';
import 'package:tenkai/core/services/storage_service.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
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
      AuthInterceptor(storage: StorageService()),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) => DioClient());
