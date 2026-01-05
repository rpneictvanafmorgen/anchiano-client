import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

typedef UnauthorizedCallback = void Function();

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient._(this._dio, this._secureStorage);

  factory ApiClient({
    UnauthorizedCallback? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final storage = const FlutterSecureStorage();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;

          if (status == 401) {
            
            await storage.delete(key: 'jwt');

            if (onUnauthorized != null) {
              onUnauthorized();
            }
          }

          handler.next(error);
        },
      ),
    );

    return ApiClient._(dio, storage);
  }

  Dio get dio => _dio;

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: 'jwt', value: token);

  Future<void> clearToken() =>
      _secureStorage.delete(key: 'jwt');

  Future<String?> getToken() =>
      _secureStorage.read(key: 'jwt');
}
