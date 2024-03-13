// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
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

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

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
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
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
  _$FlutterDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TaskDao? _taskDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Task` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `message` TEXT NOT NULL, `isRead` INTEGER, `timestamp` INTEGER NOT NULL, `status` INTEGER, `type` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TaskDao get taskDao {
    return _taskDaoInstance ??= _$TaskDao(database, changeListener);
  }
}

class _$TaskDao extends TaskDao {
  _$TaskDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _taskInsertionAdapter = InsertionAdapter(
            database,
            'Task',
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'message': item.message,
                  'isRead': item.isRead == null ? null : (item.isRead! ? 1 : 0),
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'status': item.status?.index,
                  'type': _taskTypeConverter.encode(item.type)
                },
            changeListener),
        _taskUpdateAdapter = UpdateAdapter(
            database,
            'Task',
            ['id'],
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'message': item.message,
                  'isRead': item.isRead == null ? null : (item.isRead! ? 1 : 0),
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'status': item.status?.index,
                  'type': _taskTypeConverter.encode(item.type)
                },
            changeListener),
        _taskDeletionAdapter = DeletionAdapter(
            database,
            'Task',
            ['id'],
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'message': item.message,
                  'isRead': item.isRead == null ? null : (item.isRead! ? 1 : 0),
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'status': item.status?.index,
                  'type': _taskTypeConverter.encode(item.type)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Task> _taskInsertionAdapter;

  final UpdateAdapter<Task> _taskUpdateAdapter;

  final DeletionAdapter<Task> _taskDeletionAdapter;

  @override
  Future<Task?> findTaskById(int id) async {
    return _queryAdapter.query('SELECT * FROM task WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['isRead'] == null ? null : (row['isRead'] as int) != 0,
            row['message'] as String,
            _dateTimeConverter.decode(row['timestamp'] as int),
            row['status'] == null
                ? null
                : TaskStatus.values[row['status'] as int],
            _taskTypeConverter.decode(row['type'] as String?)),
        arguments: [id]);
  }

  @override
  Future<List<Task>> findAllTasks() async {
    return _queryAdapter.queryList('SELECT * FROM task',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['isRead'] == null ? null : (row['isRead'] as int) != 0,
            row['message'] as String,
            _dateTimeConverter.decode(row['timestamp'] as int),
            row['status'] == null
                ? null
                : TaskStatus.values[row['status'] as int],
            _taskTypeConverter.decode(row['type'] as String?)));
  }

  @override
  Stream<List<Task>> findAllTasksAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM task',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['isRead'] == null ? null : (row['isRead'] as int) != 0,
            row['message'] as String,
            _dateTimeConverter.decode(row['timestamp'] as int),
            row['status'] == null
                ? null
                : TaskStatus.values[row['status'] as int],
            _taskTypeConverter.decode(row['type'] as String?)),
        queryableName: 'task',
        isView: false);
  }

  @override
  Stream<int?> findUniqueMessagesCountAsStream() {
    return _queryAdapter.queryStream('SELECT DISTINCT COUNT(message) FROM task',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        queryableName: 'task',
        isView: false);
  }

  @override
  Stream<List<Task>> findAllTasksByStatusAsStream(TaskStatus status) {
    return _queryAdapter.queryListStream('SELECT * FROM task WHERE status = ?1',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['isRead'] == null ? null : (row['isRead'] as int) != 0,
            row['message'] as String,
            _dateTimeConverter.decode(row['timestamp'] as int),
            row['status'] == null
                ? null
                : TaskStatus.values[row['status'] as int],
            _taskTypeConverter.decode(row['type'] as String?)),
        arguments: [status.index],
        queryableName: 'task',
        isView: false);
  }

  @override
  Future<int?> updateTypeById(
    TaskType type,
    int id,
  ) async {
    return _queryAdapter.query(
        'UPDATE OR ABORT Task SET type = ?1 WHERE id = ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [type.index, id]);
  }

  @override
  Future<void> insertTask(Task task) async {
    await _taskInsertionAdapter.insert(task, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertTasks(List<Task> tasks) async {
    await _taskInsertionAdapter.insertList(tasks, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _taskUpdateAdapter.update(task, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTasks(List<Task> task) async {
    await _taskUpdateAdapter.updateList(task, OnConflictStrategy.abort);
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

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _taskTypeConverter = TaskTypeConverter();
