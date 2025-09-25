import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_db/task_extras.dart';
import '../../data/local_db/task_extras_dao.dart' as dao;
import '../../data/local_db/task_local_db.dart';
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
    final localTodos = await _getAllLocalTasks();
    final localOnlyTasks = localTodos.where((t) => (t.id ?? 0) < 0).toList();

    try {
      final apiTodos = await ref
          .read(todoRepositoryProvider)
          .getTasksPaged(start: 0, limit: _pageSize);
      final allTodos = [...localOnlyTasks, ...apiTodos];

      _loaded = apiTodos.length;
      _hasMore = apiTodos.length == _pageSize;
      state = AsyncData(allTodos);
    } catch (err, _) {
      state = AsyncData(localTodos);
      _loaded = 0;
      _hasMore = false;
    }
  }

  Future<List<TodoModel>> _getAllLocalTasks() async {
    final db = await TaskLocalDb.instance.database;
    final rows = await db.query(TaskLocalDb.tableFull, orderBy: 'task_id DESC');

    return rows
        .map(
          (row) => TodoModel(
            id: row['task_id'] as int,
            title: row['title'] as String,
            completed: (row['completed'] as int) == 1,
            userId: 1, // Default user ID
          ),
        )
        .toList();
  }

  Future<void> refresh() async => _fetchAndSet();

  void _setData(List<TodoModel> todos) {
    state = AsyncData(List<TodoModel>.unmodifiable(todos));
  }

  Future<void> addTodo(TodoModel newTodo) async {
    final tempId = newTodo.id ?? (DateTime.now().millisecondsSinceEpoch * -1);
    final optimistic = newTodo.copyWith(id: tempId);
    final current = state.value ?? <TodoModel>[];
    _setData(<TodoModel>[optimistic, ...current]);
    final existingExtras = await ref
        .read(dao.taskExtrasDaoProvider)
        .findByTaskId(tempId);
    await TaskLocalDb.instance.upsertFull(
      taskId: tempId,
      title: newTodo.title,
      completed: newTodo.completed,
      description: existingExtras?.description ?? '',
      dueDateMillis: existingExtras?.dueDate?.millisecondsSinceEpoch,
      priority: (existingExtras?.priority ?? TaskPriority.medium).name,
      status: (existingExtras?.status ?? TaskStatus.todo).name,
      assignedUserId: existingExtras?.assignedUserId,
      assignedUserName: existingExtras?.assignedUserName,
      category: existingExtras?.category,
      reminderDateMillis: existingExtras?.reminderDate?.millisecondsSinceEpoch,
    );

    try {
      final created = await ref
          .read(todoRepositoryProvider)
          .createTask(newTodo);
      if (created.id != null) {
        final updatedList = state.value?.map((t) {
          if ((t.id ?? tempId) == tempId) {
            return t.copyWith(id: created.id);
          }
          return t;
        }).toList();
        if (updatedList != null) _setData(updatedList);
        final extras = await ref
            .read(dao.taskExtrasDaoProvider)
            .findByTaskId(tempId);

        if (extras != null) {
          await ref
              .read(dao.taskExtrasDaoProvider)
              .upsert(extras.copyWith(taskId: created.id!));
          await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(tempId);
        }
        await TaskLocalDb.instance.deleteFullById(tempId);
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
    } catch (err, _) {}
  }

  Future<void> updateTodo(int id, TodoModel updatedTodo) async {
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    current[index] = updatedTodo.copyWith(id: id);
    _setData(current);
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
    if (id > 0) {
      try {
        await ref.read(todoRepositoryProvider).updateTask(id, updatedTodo);
      } catch (err, _) {}
    }
  }

  Future<void> deleteTodo(int id) async {
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    current.removeAt(index);
    _setData(current);
    try {
      await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(id);
    } catch (_) {}
    try {
      await TaskLocalDb.instance.deleteFullById(id);
    } catch (_) {}
    if (id > 0) {
      try {
        await ref.read(todoRepositoryProvider).deleteTask(id);
      } catch (err, _) {}
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
      final localTasks = current.where((t) => (t.id ?? 0) < 0).toList();
      final apiTasks = current.where((t) => (t.id ?? 0) > 0).toList();
      _setData([...localTasks, ...apiTasks, ...next]);
    } catch (_) {}
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<TodoModel>>>((ref) {
      return TodoController(ref: ref);
    });
