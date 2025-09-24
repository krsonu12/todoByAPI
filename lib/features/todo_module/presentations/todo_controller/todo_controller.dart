import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/todo_model.dart';
import '../../domain/todo_provider.dart';

class TodoController extends StateNotifier<AsyncValue<List<TodoModel>>> {
  TodoController({required this.ref}) : super(const AsyncLoading()) {
    _fetchAndSet();
  }

  final Ref ref;

  Future<void> _fetchAndSet() async {
    try {
      final todos = await ref.read(todoRepositoryProvider).getTasks();
      state = AsyncData(todos);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> refresh() async => _fetchAndSet();

  Future<void> addTodo(TodoModel newTodo) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).createTask(newTodo);
      await _fetchAndSet();
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> updateTodo(int id, TodoModel updatedTodo) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).updateTask(id, updatedTodo);
      await _fetchAndSet();
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> deleteTodo(int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).deleteTask(id);
      await _fetchAndSet();
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<TodoModel>>>((ref) {
      return TodoController(ref: ref);
    });
