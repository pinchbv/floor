// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autoinc_test.dart';

// **************************************************************************
// FlatGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FlatTestDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TestDatabaseBuilder databaseBuilder(String name) =>
      _$TestDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TestDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$TestDatabaseBuilder(null);
}

class _$TestDatabaseBuilder {
  _$TestDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$TestDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$TestDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<TestDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$TestDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$TestDatabase extends TestDatabase {
  _$TestDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AIDao? _aiDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
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
            'CREATE TABLE IF NOT EXISTS `AutoIncEntity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `decimal` REAL NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AIDao get aiDao {
    return _aiDaoInstance ??= _$AIDao(database, changeListener);
  }
}

class _$AIDao extends AIDao {
  _$AIDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _autoIncEntityInsertionAdapter = InsertionAdapter(
            database,
            'AutoIncEntity',
            (AutoIncEntity item) =>
                <String, Object?>{'id': item.id, 'decimal': item.decimal});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AutoIncEntity> _autoIncEntityInsertionAdapter;

  @override
  Future<AutoIncEntity?> findWithId(int val) async {
    return _queryAdapter.query('SELECT * FROM AutoIncEntity where id = ?1',
        mapper: (Map<String, Object?> row) =>
            AutoIncEntity(row['decimal'] as double, id: row['id'] as int?),
        arguments: [val]);
  }

  @override
  Future<List<AutoIncEntity>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM AutoIncEntity',
        mapper: (Map<String, Object?> row) =>
            AutoIncEntity(row['decimal'] as double, id: row['id'] as int?));
  }

  @override
  Future<void> insertAIEntity(AutoIncEntity e) async {
    await _autoIncEntityInsertionAdapter.insert(e, OnConflictStrategy.abort);
  }
}
