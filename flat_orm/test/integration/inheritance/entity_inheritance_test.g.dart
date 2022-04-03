// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_inheritance_test.dart';

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

  CommentDao? _commentDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `comments` (`author` TEXT NOT NULL, `content` TEXT NOT NULL, `id` INTEGER NOT NULL, `create_time` TEXT NOT NULL, `update_time` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CommentDao get commentDao {
    return _commentDaoInstance ??= _$CommentDao(database, changeListener);
  }
}

class _$CommentDao extends CommentDao {
  _$CommentDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _commentInsertionAdapter = InsertionAdapter(
            database,
            'comments',
            (Comment item) => <String, Object?>{
                  'author': item.author,
                  'content': item.content,
                  'id': item.id,
                  'create_time': item.createTime,
                  'update_time': item.updateTime
                }),
        _commentDeletionAdapter = DeletionAdapter(
            database,
            'comments',
            ['id'],
            (Comment item) => <String, Object?>{
                  'author': item.author,
                  'content': item.content,
                  'id': item.id,
                  'create_time': item.createTime,
                  'update_time': item.updateTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Comment> _commentInsertionAdapter;

  final DeletionAdapter<Comment> _commentDeletionAdapter;

  @override
  Future<Comment?> findCommentById(int id) async {
    return _queryAdapter.query('SELECT * FROM comments WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Comment(
            row['id'] as int, row['author'] as String,
            content: row['content'] as String,
            createTime: row['create_time'] as String?,
            updateTime: row['update_time'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> addComment(Comment c) async {
    await _commentInsertionAdapter.insert(c, OnConflictStrategy.abort);
  }

  @override
  Future<void> removeComment(Comment c) async {
    await _commentDeletionAdapter.delete(c);
  }
}
