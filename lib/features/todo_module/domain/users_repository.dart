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
  static const String _base = 'https://jsonplaceholder.typicode.com';

  Future<List<AppUser>> getUsers() async {
    final res = await client.get('$_base/users');
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((m) => AppUser(
                id: (m['id'] as num?)?.toInt() ?? 0,
                name: (m['name'] as String?) ?? 'Unknown',
              ))
          .toList();
    }
    return <AppUser>[];
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.read(unauthenticatedDioProvider);
  return UsersRepository(client: dio);
});

