import 'package:dio/dio.dart';

typedef TokenProvider = String? Function();
typedef LogoutCallback = void Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getToken, required this.onLogout});

  final TokenProvider getToken;
  final LogoutCallback onLogout;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      super.onRequest(options, handler);
    } else {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Token not found',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onLogout();
    }
    super.onError(err, handler);
  }
}
