import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final Dio dio = ref.read(unauthenticatedDioProvider);
  return AuthService(client: dio);
});
