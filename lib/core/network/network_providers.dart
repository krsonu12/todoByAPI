import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_token_provider.dart';
import 'network_client.dart';

final networkClientProvider = Provider<NetworkClient>((ref) {
  String? getToken() => ref.read(authTokenProvider);
  final onLogout = ref.read(logoutCallbackProvider);
  return NetworkClient(getToken: getToken, onLogout: onLogout);
});

final authenticatedDioProvider = Provider<Dio>((ref) {
  return ref.watch(networkClientProvider).authenticatedClient;
});

final unauthenticatedDioProvider = Provider<Dio>((ref) {
  return ref.watch(networkClientProvider).unauthenticatedClient;
});
