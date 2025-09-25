import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/local_db/task_extras_dao.dart';
import 'todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final Dio dio = ref.read(unauthenticatedDioProvider);
  return TodoRepository(client: dio);
});

final taskExtrasDaoProvider = Provider<TaskExtrasDao>((ref) {
  return TaskExtrasDao();
});
