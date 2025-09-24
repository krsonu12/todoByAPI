import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_extras.dart';
import '../../data/task_extras_dao.dart' as dao;
import '../../data/task_local_db.dart';
import '../../data/todo_model.dart';
import '../../domain/todo_provider.dart' hide taskExtrasDaoProvider;

class TodoController extends StateNotifier<AsyncValue<List<TodoModel>>> {
  TodoController({required this.ref}) : super(const AsyncLoading()) {
    _fetchAndSet();
  }

  final Ref ref;
  static const int _pageSize = 20;
  int _loaded = 0;
  bool _hasMore = true;

  Future<void> _fetchAndSet() async {
    try {
      final todos = await ref
          .read(todoRepositoryProvider)
          .getTasksPaged(start: 0, limit: _pageSize);
      _loaded = todos.length;
      _hasMore = todos.length == _pageSize;
      state = AsyncData(todos);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> refresh() async => _fetchAndSet();

  void _setData(List<TodoModel> todos) {
    state = AsyncData(List<TodoModel>.unmodifiable(todos));
  }

  Future<void> addTodo(TodoModel newTodo) async {
    final previous = state;
    // optimistic: insert with temp negative id to avoid clashes
    final tempId = DateTime.now().millisecondsSinceEpoch * -1;
    final optimistic = newTodo.copyWith(id: tempId);
    final current = state.value ?? <TodoModel>[];
    _setData(<TodoModel>[optimistic, ...current]);
    try {
      final created = await ref
          .read(todoRepositoryProvider)
          .createTask(newTodo);
      final updatedList = state.value?.map((t) {
        if ((t.id ?? tempId) == tempId) {
          // keep server id if provided, otherwise keep optimistic
          return t.copyWith(id: created.id ?? t.id);
        }
        return t;
      }).toList();
      if (updatedList != null) _setData(updatedList);
      // migrate extras saved under tempId to real id and persist full row for UI
      if (created.id != null) {
        final extras = await ref
            .read(dao.taskExtrasDaoProvider)
            .findByTaskId(tempId);
        if (extras != null) {
          await ref
              .read(dao.taskExtrasDaoProvider)
              .upsert(extras.copyWith(taskId: created.id!));
          await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(tempId);
        }
        await TaskLocalDb.instance.upsertFull(
          taskId: created.id!,
          title: created.title,
          completed: created.completed,
          description: extras?.description ?? '',
          dueDateMillis: extras?.dueDate?.millisecondsSinceEpoch,
          priority: (extras?.priority ?? TaskPriority.medium).name,
          status: (extras?.status ?? TaskStatus.todo).name,
          assignedUserId: extras?.assignedUserId,
          assignedUserName: extras?.assignedUserName,
          category: extras?.category,
          reminderDateMillis: extras?.reminderDate?.millisecondsSinceEpoch,
        );
      }
    } catch (err, st) {
      state = previous; // revert
      state = AsyncError(err, st);
    }
  }

  Future<void> updateTodo(int id, TodoModel updatedTodo) async {
    final previous = state;
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    final old = current[index];
    current[index] = updatedTodo.copyWith(id: id);
    _setData(current);
    try {
      await ref.read(todoRepositoryProvider).updateTask(id, updatedTodo);
      // persist full record locally with latest extras if any
      final extras = await ref.read(dao.taskExtrasDaoProvider).findByTaskId(id);
      await TaskLocalDb.instance.upsertFull(
        taskId: id,
        title: updatedTodo.title,
        completed: updatedTodo.completed,
        description: extras?.description ?? '',
        dueDateMillis: extras?.dueDate?.millisecondsSinceEpoch,
        priority: (extras?.priority ?? TaskPriority.medium).name,
        status: (extras?.status ?? TaskStatus.todo).name,
        assignedUserId: extras?.assignedUserId,
        assignedUserName: extras?.assignedUserName,
        category: extras?.category,
        reminderDateMillis: extras?.reminderDate?.millisecondsSinceEpoch,
      );
    } catch (err, st) {
      // revert
      final revert = List<TodoModel>.from(state.value ?? <TodoModel>[]);
      final idx = revert.indexWhere((t) => (t.id ?? -1) == id);
      if (idx != -1) {
        revert[idx] = old;
        _setData(revert);
      } else {
        state = previous;
      }
      state = AsyncError(err, st);
    }
  }

  Future<void> deleteTodo(int id) async {
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    final removed = current.removeAt(index);
    _setData(current);
    try {
      await ref.read(todoRepositoryProvider).deleteTask(id);
      // remove local persisted records
      try {
        await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(id);
      } catch (_) {}
      try {
        await TaskLocalDb.instance.deleteFullById(id);
      } catch (_) {}
    } catch (err, st) {
      // revert the removal
      final revert = List<TodoModel>.from(state.value ?? <TodoModel>[]);
      revert.insert(index, removed);
      _setData(revert);
      state = AsyncError(err, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    try {
      final next = await ref
          .read(todoRepositoryProvider)
          .getTasksPaged(start: _loaded, limit: _pageSize);
      _loaded += next.length;
      _hasMore = next.length == _pageSize;
      _setData([...current, ...next]);
    } catch (_) {
      // ignore load more errors to avoid breaking the list
    }
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<TodoModel>>>((ref) {
      return TodoController(ref: ref);
    });
