import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient._(this._dio, this._secureStorage);

  factory ApiClient() {
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
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
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
