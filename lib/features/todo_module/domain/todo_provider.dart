import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final Dio dio = ref.read(unauthenticatedDioProvider);
  return TodoRepository(client: dio);
});

// Removed controller and state providers; moved to presentations/todo_controller/todo_controller.dart
