import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/todo_model.dart';
import 'todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final Dio dio = ref.read(unauthenticatedDioProvider);
  return TodoRepository(client: dio);
});

final todosProvider = FutureProvider<List<TodoModel>>((ref) async {
  final repo = ref.read(todoRepositoryProvider);
  return repo.getTasks();
});

class TodoController extends StateNotifier<AsyncValue<List<TodoModel>>> {
  TodoController({required this.ref}) : super(const AsyncLoading()) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final todos = await ref.read(todoRepositoryProvider).getTasks();
      state = AsyncData(todos);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> refresh() async => _load();

  Future<void> addTodo(TodoModel newTodo) async {
    final current = state.value ?? <TodoModel>[];
    state = AsyncData(<TodoModel>[...current, newTodo]);
    try {
      final created = await ref
          .read(todoRepositoryProvider)
          .createTask(newTodo);
      final updated = [...current, created];
      state = AsyncData(updated);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> updateTodo(int id, TodoModel updatedTodo) async {
    final current = state.value ?? <TodoModel>[];
    final index = current.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final optimistic = [...current]..[index] = updatedTodo;
    state = AsyncData(optimistic);
    try {
      final saved = await ref
          .read(todoRepositoryProvider)
          .updateTask(id, updatedTodo);
      final next = [...current]..[index] = saved;
      state = AsyncData(next);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> deleteTodo(int id) async {
    final current = state.value ?? <TodoModel>[];
    final next = current.where((t) => t.id != id).toList();
    state = AsyncData(next);
    try {
      await ref.read(todoRepositoryProvider).deleteTask(id);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<TodoModel>>>((ref) {
      return TodoController(ref: ref);
    });
