import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:todo_app_task/core/network/api_paths.dart';

import '../data/userModel/user_model.dart';
import '../data/models/auth_result.dart';

class AuthService {
  AuthService({required this.client});

  final Dio client;

  Future<AuthResult> register({
    String? username,
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await client.post(
      ApiPaths.register,
      data: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
      },
    );
    final dynamic data = response.data;
    log(response.data.toString());
    if (data is Map && data['token'] is String) {
      return AuthResult(
        id: (data['id'] is int) ? data['id'] as int : null,
        token: data['token'] as String,
      );
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Token missing in register response',
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await client.post(
      ApiPaths.login,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final dynamic data = response.data;
    if (data is Map && data['token'] is String) {
      return AuthResult(token: data['token'] as String);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Token missing in login response',
    );
  }

  Future<UserModel> fetchUser(int id) async {
    final Response<dynamic> response = await client.get('/users/$id');
    final dynamic data = response.data;
    final dynamic payload = (data is Map) ? data['data'] : null;
    if (payload is Map<String, dynamic>) {
      return UserModel.fromJson(payload);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Invalid user response',
    );
  }
}
