import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TaskLocalDb {
  TaskLocalDb._();
  static final TaskLocalDb instance = TaskLocalDb._();

  static const String _dbName = 'tasks.db';
  static const int _dbVersion = 1;

  static const String tableExtras = 'task_extras';

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
            assigned_user_name TEXT NULL
          );
        ''');
      },
    );
  }
}
