import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final token = response.data['token'] as String;
    await _apiClient.saveToken(token);
    return token;
  }

  Future<String> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/auth/register',
      data: {
        'displayName': displayName,
        'email': email,
        'password': password,
      },
    );

    final token = response.data['token'] as String;
    await _apiClient.saveToken(token);
    return token;
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<bool> hasToken() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() => _apiClient.getToken();
}
