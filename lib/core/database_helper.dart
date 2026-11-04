import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  int? id;
  String username;
  String title;
  String description;
  bool done;
  DateTime createdAt;
  DateTime? dueDate;
  String priority;
  String category;

  Task({
    this.id,
    this.username = 'admin',
    required this.title,
    this.description = '',
    this.done = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = 'medium',
    this.category = '',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'title': title,
      'description': description,
      'done': done ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      username: map['username'] as String? ?? 'admin',
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      done: (map['done'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      priority: map['priority'] as String? ?? 'medium',
      category: map['category'] as String? ?? '',
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const int _dbVersion = 4;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL DEFAULT 'admin',
        title TEXT NOT NULL,
        description TEXT,
        done INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        dueDate INTEGER,
        priority TEXT NOT NULL DEFAULT 'medium',
        category TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tasks ADD COLUMN username TEXT NOT NULL DEFAULT 'admin'",
      );
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tasks ADD COLUMN dueDate INTEGER');
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'medium'",
      );
      await db.execute('ALTER TABLE tasks ADD COLUMN category TEXT');
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks({String username = 'admin'}) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
