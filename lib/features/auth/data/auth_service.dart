import 'package:dio/dio.dart';
import 'package:todo_app_task/core/network/api_paths.dart';

class AuthService {
  AuthService({required this.client});

  final Dio client;

  Future<String> register({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await client.post(
      ApiPaths.register,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final dynamic data = response.data;
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Token missing in register response',
    );
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await client.post(
      ApiPaths.login,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final dynamic data = response.data;
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Token missing in login response',
    );
  }
}
