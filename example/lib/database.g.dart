// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorFlutterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder databaseBuilder(String name) =>
      _$FlutterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDatabaseBuilder(null);
}

class _$FlutterDatabaseBuilder {
  _$FlutterDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$FlutterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$FlutterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDatabase extends FlutterDatabase {
  _$FlutterDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TaskDao _taskDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Task` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `message` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  TaskDao get taskDao {
    return _taskDaoInstance ??= _$TaskDao(database, changeListener);
  }
}

class _$TaskDao extends TaskDao {
  _$TaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _taskInsertionAdapter = InsertionAdapter(
            database,
            'Task',
            (Task item) =>
                <String, dynamic>{'id': item.id, 'message': item.message},
            changeListener),
        _taskUpdateAdapter = UpdateAdapter(
            database,
            'Task',
            ['id'],
            (Task item) =>
                <String, dynamic>{'id': item.id, 'message': item.message},
            changeListener),
        _taskDeletionAdapter = DeletionAdapter(
            database,
            'Task',
            ['id'],
            (Task item) =>
                <String, dynamic>{'id': item.id, 'message': item.message},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _taskMapper = (Map<String, dynamic> row) =>
      Task(row['id'] as int, row['message'] as String);

  final InsertionAdapter<Task> _taskInsertionAdapter;

  final UpdateAdapter<Task> _taskUpdateAdapter;

  final DeletionAdapter<Task> _taskDeletionAdapter;

  @override
  Future<Task> findTaskById(int id) async {
    return _queryAdapter.query('SELECT * FROM task WHERE id = ?',
        arguments: <dynamic>[id], mapper: _taskMapper);
  }

  @override
  Future<List<Task>> findAllTasks() async {
    return _queryAdapter.queryList('SELECT * FROM task', mapper: _taskMapper);
  }

  @override
  Stream<List<Task>> findAllTasksAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM task',
        tableName: 'Task', mapper: _taskMapper);
  }

  @override
  Future<void> insertTask(Task task) async {
    await _taskInsertionAdapter.insert(task, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> insertTasks(List<Task> tasks) async {
    await _taskInsertionAdapter.insertList(
        tasks, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _taskUpdateAdapter.update(task, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateTasks(List<Task> task) async {
    await _taskUpdateAdapter.updateList(task, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> deleteTask(Task task) async {
    await _taskDeletionAdapter.delete(task);
  }

  @override
  Future<void> deleteTasks(List<Task> tasks) async {
    await _taskDeletionAdapter.deleteList(tasks);
  }
}
