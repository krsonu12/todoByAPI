import 'package:dio/dio.dart';

import 'api_paths.dart';
import 'auth_interceptor.dart';

class NetworkClient {
  NetworkClient._internal({
    required this.unauthenticatedClient,
    required this.authenticatedClient,
  });

  factory NetworkClient({
    required String? Function() getToken,
    required void Function() onLogout,
  }) {
    final Dio unauthenticatedClient = Dio(
      BaseOptions(
        baseUrl: ApiPaths.baseUrl,
        headers: <String, dynamic>{'x-api-key': 'reqres-free-v1'},
      ),
    );

    final Dio authenticatedClient =
        Dio(
            BaseOptions(
              baseUrl: ApiPaths.baseUrl,
              headers: <String, dynamic>{'x-api-key': 'reqres-free-v1'},
            ),
          )
          ..interceptors.add(
            AuthInterceptor(getToken: getToken, onLogout: onLogout),
          );

    return NetworkClient._internal(
      unauthenticatedClient: unauthenticatedClient,
      authenticatedClient: authenticatedClient,
    );
  }

  final Dio unauthenticatedClient;
  final Dio authenticatedClient;
}
