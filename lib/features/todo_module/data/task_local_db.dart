import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaskLocalDb {
  TaskLocalDb._();
  static final TaskLocalDb instance = TaskLocalDb._();

  static const String _dbName = 'tasks.db';
  static const int _dbVersion = 3;

  static const String tableExtras = 'task_extras';
  static const String tableFull = 'task_full';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableExtras (
            task_id INTEGER PRIMARY KEY,
            description TEXT NOT NULL DEFAULT '',
            due_date INTEGER NULL,
            priority TEXT NOT NULL,
            status TEXT NOT NULL,
            assigned_user_id INTEGER NULL,
            assigned_user_name TEXT NULL,
            category TEXT NULL,
            reminder_date INTEGER NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE $tableFull (
            task_id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            completed INTEGER NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            due_date INTEGER NULL,
            priority TEXT NOT NULL,
            status TEXT NOT NULL,
            assigned_user_id INTEGER NULL,
            assigned_user_name TEXT NULL,
            category TEXT NULL,
            reminder_date INTEGER NULL
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tableFull (
              task_id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              completed INTEGER NOT NULL,
              description TEXT NOT NULL DEFAULT '',
              due_date INTEGER NULL,
              priority TEXT NOT NULL,
              status TEXT NOT NULL,
              assigned_user_id INTEGER NULL,
              assigned_user_name TEXT NULL,
              category TEXT NULL,
              reminder_date INTEGER NULL
            );
          ''');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $tableExtras ADD COLUMN category TEXT NULL',
          );
          await db.execute(
            'ALTER TABLE $tableExtras ADD COLUMN reminder_date INTEGER NULL',
          );
          await db.execute(
            'ALTER TABLE $tableFull ADD COLUMN category TEXT NULL',
          );
          await db.execute(
            'ALTER TABLE $tableFull ADD COLUMN reminder_date INTEGER NULL',
          );
        }
      },
    );
  }

  Future<void> upsertFull({
    required int taskId,
    required String title,
    required bool completed,
    String description = '',
    int? dueDateMillis,
    required String priority,
    required String status,
    int? assignedUserId,
    String? assignedUserName,
    String? category,
    int? reminderDateMillis,
  }) async {
    final db = await database;
    await db.insert(tableFull, <String, Object?>{
      'task_id': taskId,
      'title': title,
      'completed': completed ? 1 : 0,
      'description': description,
      'due_date': dueDateMillis,
      'priority': priority,
      'status': status,
      'assigned_user_id': assignedUserId,
      'assigned_user_name': assignedUserName,
      'category': category,
      'reminder_date': reminderDateMillis,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, Object?>?> getFullById(int taskId) async {
    final db = await database;
    final rows = await db.query(
      tableFull,
      where: 'task_id = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> deleteFullById(int taskId) async {
    final db = await database;
    await db.delete(tableFull, where: 'task_id = ?', whereArgs: [taskId]);
  }
}
