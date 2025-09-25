import 'package:dio/dio.dart';

import '../data/todo_model.dart';

class TodoRepository {
  TodoRepository({required this.client});

  final Dio client;
  static const String _base = 'https://jsonplaceholder.typicode.com';

  Future<List<TodoModel>> getTasksPaged({
    required int start,
    required int limit,
  }) async {
    final Response<dynamic> response = await client.get(
      '$_base/todos',
      queryParameters: <String, dynamic>{'_start': start, '_limit': limit},
    );
    final dynamic data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map<TodoModel>(TodoModel.fromJson)
          .toList();
    }
    return <TodoModel>[];
  }

  Future<TodoModel> createTask(TodoModel task) async {
    final Response<dynamic> response = await client.post(
      '$_base/todos',
      data: task.toJson(),
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return TodoModel.fromJson(data);
    }
    return task;
  }

  Future<TodoModel> updateTask(int id, TodoModel task) async {
    final Response<dynamic> response = await client.put(
      '$_base/todos/$id',
      data: task.toJson(),
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return TodoModel.fromJson(data);
    }
    return task;
  }

  Future<void> deleteTask(int id) async {
    await client.delete('$_base/todos/$id');
  }
}
