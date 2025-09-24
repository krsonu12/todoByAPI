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

  Future<AppUser?> getUser(int id) async {
    final Response<dynamic> res = await client.get('$_base/users/$id');
    final dynamic root = res.data;
    if (root is Map<String, dynamic>) {
      final dynamic data = root['data'];
      if (data is Map<String, dynamic>) {
        return AppUser(
          id: (data['id'] as num?)?.toInt() ?? id,
          name:
              '${(data['first_name'] as String?) ?? ''} ${(data['last_name'] as String?) ?? ''}'
                  .trim(),
        );
      }
    }
    return null;
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.read(unauthenticatedDioProvider);
  return UsersRepository(client: dio);
});
