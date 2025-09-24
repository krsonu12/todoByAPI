import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'task_extras.dart';
import 'task_local_db.dart';

class TaskExtrasDao {
  Future<void> upsert(TaskExtras extras) async {
    final db = await TaskLocalDb.instance.database;
    await db.insert(
      TaskLocalDb.tableExtras,
      _toMap(extras),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TaskExtras?> findByTaskId(int taskId) async {
    final db = await TaskLocalDb.instance.database;
    final rows = await db.query(
      TaskLocalDb.tableExtras,
      where: 'task_id = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> deleteByTaskId(int taskId) async {
    final db = await TaskLocalDb.instance.database;
    await db.delete(
      TaskLocalDb.tableExtras,
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Map<String, Object?> _toMap(TaskExtras e) {
    return {
      'task_id': e.taskId,
      'description': e.description,
      'due_date': e.dueDate?.millisecondsSinceEpoch,
      'priority': e.priority.name,
      'status': e.status.name,
      'assigned_user_id': e.assignedUserId,
      'assigned_user_name': e.assignedUserName,
    };
  }

  TaskExtras _fromMap(Map<String, Object?> row) {
    return TaskExtras(
      taskId: row['task_id'] as int,
      description: (row['description'] as String?) ?? '',
      dueDate: (row['due_date'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(row['due_date'] as int)
          : null,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (row['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == (row['status'] as String? ?? 'todo'),
        orElse: () => TaskStatus.todo,
      ),
      assignedUserId: row['assigned_user_id'] as int?,
      assignedUserName: row['assigned_user_name'] as String?,
    );
  }
}

final taskExtrasDaoProvider = Provider<TaskExtrasDao>((ref) {
  return TaskExtrasDao();
});
