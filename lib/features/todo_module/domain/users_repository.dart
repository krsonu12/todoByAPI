import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';

class AppUser {
  AppUser({required this.id, required this.name});
  final int id;
  final String name;
}

class UsersRepository {
  UsersRepository({required this.client});
  final Dio client;
  static const String _base = 'https://reqres.in/api';

  Future<List<AppUser>> getUsers() async {
    final Response<dynamic> res = await client.get('$_base/users');
    log("user data: ${res.data.toString()}");
    final dynamic root = res.data;
    if (root is Map<String, dynamic>) {
      final dynamic list = root['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(
              (m) => AppUser(
                id: (m['id'] as num?)?.toInt() ?? 0,
                name:
                    '${(m['first_name'] as String?) ?? ''} ${(m['last_name'] as String?) ?? ''}'
                        .trim(),
              ),
            )
            .toList();
      }
    }
    return <AppUser>[];
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.read(unauthenticatedDioProvider);
  return UsersRepository(client: dio);
});
