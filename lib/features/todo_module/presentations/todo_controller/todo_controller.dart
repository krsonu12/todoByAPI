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
    // Always try to load local tasks first, regardless of API
    final localTodos = await _getAllLocalTasks();

    // Separate local-only (negative ID) from synced (positive ID) tasks
    final localOnlyTasks = localTodos.where((t) => (t.id ?? 0) < 0).toList();

    try {
      // Fetch from API
      final apiTodos = await ref
          .read(todoRepositoryProvider)
          .getTasksPaged(start: 0, limit: _pageSize);

      // Merge: local-only tasks + API tasks (API takes precedence over local synced tasks)
      final allTodos = [...localOnlyTasks, ...apiTodos];

      _loaded = apiTodos.length;
      _hasMore = apiTodos.length == _pageSize;
      state = AsyncData(allTodos);
    } catch (err, _) {
      // If API fails, use all local tasks (both local-only and synced)
      state = AsyncData(localTodos);
      _loaded = 0;
      _hasMore = false;
    }
  }

  /// Get all tasks from local database
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
    // Use the provided ID if it exists (for pre-created tasks), otherwise generate one
    final tempId = newTodo.id ?? (DateTime.now().millisecondsSinceEpoch * -1);
    final optimistic = newTodo.copyWith(id: tempId);
    final current = state.value ?? <TodoModel>[];

    // Immediately add to UI
    _setData(<TodoModel>[optimistic, ...current]);

    // Get existing extras if they exist
    final existingExtras = await ref
        .read(dao.taskExtrasDaoProvider)
        .findByTaskId(tempId);

    // Store in local database immediately with temp ID
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
      // Try to sync with API
      final created = await ref
          .read(todoRepositoryProvider)
          .createTask(newTodo);

      // If API call succeeds, update the task with server ID
      if (created.id != null) {
        final updatedList = state.value?.map((t) {
          if ((t.id ?? tempId) == tempId) {
            return t.copyWith(id: created.id);
          }
          return t;
        }).toList();
        if (updatedList != null) _setData(updatedList);

        // Migrate local data from temp ID to server ID
        final extras = await ref
            .read(dao.taskExtrasDaoProvider)
            .findByTaskId(tempId);

        if (extras != null) {
          await ref
              .read(dao.taskExtrasDaoProvider)
              .upsert(extras.copyWith(taskId: created.id!));
          await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(tempId);
        }

        // Update local database with server ID
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
    } catch (err, _) {
      // If API fails, keep the task locally with temp ID
      // Don't revert the UI state - keep the task visible
      // The task will remain in local storage and be visible in the UI
    }
  }

  Future<void> updateTodo(int id, TodoModel updatedTodo) async {
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    current[index] = updatedTodo.copyWith(id: id);
    _setData(current);

    // Always update local database first
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

    // Only try to sync with API if it's not a local-only task (positive ID)
    if (id > 0) {
      try {
        await ref.read(todoRepositoryProvider).updateTask(id, updatedTodo);
      } catch (err, _) {
        // If API sync fails, keep local changes but show error
        // Don't revert - keep the local changes
      }
    }
  }

  Future<void> deleteTodo(int id) async {
    final current = List<TodoModel>.from(state.value ?? <TodoModel>[]);
    final index = current.indexWhere((t) => (t.id ?? -1) == id);
    if (index == -1) return;
    current.removeAt(index);
    _setData(current);

    // Always remove from local database
    try {
      await ref.read(dao.taskExtrasDaoProvider).deleteByTaskId(id);
    } catch (_) {}
    try {
      await TaskLocalDb.instance.deleteFullById(id);
    } catch (_) {}

    // Only try to delete from API if it's not a local-only task (positive ID)
    if (id > 0) {
      try {
        await ref.read(todoRepositoryProvider).deleteTask(id);
      } catch (err, _) {
        // If API deletion fails, still keep the task deleted locally
        // Don't revert the deletion - the task is gone from local storage
      }
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

      // Separate local-only tasks from API tasks
      final localTasks = current.where((t) => (t.id ?? 0) < 0).toList();
      final apiTasks = current.where((t) => (t.id ?? 0) > 0).toList();

      // Combine: local tasks first, then existing API tasks, then new API tasks
      _setData([...localTasks, ...apiTasks, ...next]);
    } catch (_) {
      // ignore load more errors to avoid breaking the list
    }
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<TodoModel>>>((ref) {
      return TodoController(ref: ref);
    });
