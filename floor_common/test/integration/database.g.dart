// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $TestDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $TestDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $TestDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<TestDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorTestDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $TestDatabaseBuilderContract databaseBuilder(String name) =>
      _$TestDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $TestDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$TestDatabaseBuilder(null);
}

class _$TestDatabaseBuilder implements $TestDatabaseBuilderContract {
  _$TestDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $TestDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $TestDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
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

  PersonDao? _personDaoInstance;

  DogDao? _dogDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
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
            'CREATE TABLE IF NOT EXISTS `person` (`id` INTEGER, `custom_name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `dog` (`id` INTEGER, `name` TEXT NOT NULL, `nick_name` TEXT NOT NULL, `owner_id` INTEGER NOT NULL, FOREIGN KEY (`owner_id`) REFERENCES `person` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_person_custom_name` ON `person` (`custom_name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PersonDao get personDao {
    return _personDaoInstance ??= _$PersonDao(database, changeListener);
  }

  @override
  DogDao get dogDao {
    return _dogDaoInstance ??= _$DogDao(database, changeListener);
  }
}

class _$PersonDao extends PersonDao {
  _$PersonDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'person',
            (Person item) =>
                <String, Object?>{'id': item.id, 'custom_name': item.name},
            changeListener),
        _personUpdateAdapter = UpdateAdapter(
            database,
            'person',
            ['id'],
            (Person item) =>
                <String, Object?>{'id': item.id, 'custom_name': item.name},
            changeListener),
        _personDeletionAdapter = DeletionAdapter(
            database,
            'person',
            ['id'],
            (Person item) =>
                <String, Object?>{'id': item.id, 'custom_name': item.name},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Person> _personInsertionAdapter;

  final UpdateAdapter<Person> _personUpdateAdapter;

  final DeletionAdapter<Person> _personDeletionAdapter;

  @override
  Future<List<Person>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM person',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String));
  }

  @override
  Stream<List<Person>> findAllPersonsAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM person',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        queryableName: 'person',
        isView: false);
  }

  @override
  Future<Person?> findPersonById(int id) async {
    return _queryAdapter.query('SELECT * FROM person WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [id]);
  }

  @override
  Stream<Person?> findPersonByIdAsStream(int id) {
    return _queryAdapter.queryStream('SELECT * FROM person WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [id],
        queryableName: 'person',
        isView: false);
  }

  @override
  Stream<int?> uniqueRecordsCountAsStream() {
    return _queryAdapter.queryStream('SELECT DISTINCT COUNT(id) FROM person',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        queryableName: 'person',
        isView: false);
  }

  @override
  Future<Person?> findPersonByIdAndName(
    int id,
    String name,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM person WHERE id = ?1 AND custom_name = ?2',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [id, name]);
  }

  @override
  Future<List<Person>> findPersonsWithIds(List<int> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE id IN (' + _sqliteVariablesForIds + ')',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [...ids]);
  }

  @override
  Future<List<Person>> findPersonsWithNames(List<String> names) async {
    const offset = 1;
    final _sqliteVariablesForNames =
        Iterable<String>.generate(names.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name IN (' +
            _sqliteVariablesForNames +
            ')',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [...names]);
  }

  @override
  Future<List<Person>> findPersonsWithNamesComplex(
    int reference,
    List<String> names,
    List<String> moreNames,
  ) async {
    int offset = 2;
    final _sqliteVariablesForNames =
        Iterable<String>.generate(names.length, (i) => '?${i + offset}')
            .join(',');
    offset += names.length;
    final _sqliteVariablesForMoreNames =
        Iterable<String>.generate(moreNames.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name IN (' +
            _sqliteVariablesForNames +
            ') AND id>=?1 OR custom_name IN (' +
            _sqliteVariablesForMoreNames +
            ') AND id<=?1',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [reference, ...names, ...moreNames]);
  }

  @override
  Future<List<Person>> findPersonsWithNamesLike(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name LIKE ?1',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String),
        arguments: [name]);
  }

  @override
  Future<List<Person>> findPersonsWithEmptyName() async {
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name == \'\'',
        mapper: (Map<String, Object?> row) =>
            Person(row['id'] as int?, row['custom_name'] as String));
  }

  @override
  Future<void> deleteAllPersons() async {
    await _queryAdapter.queryNoReturn('DELETE FROM person');
  }

  @override
  Stream<List<Dog>> findAllDogsOfPersonAsStream(int id) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM dog WHERE owner_id = ?1',
        mapper: (Map<String, Object?> row) => Dog(
            row['id'] as int?,
            row['name'] as String,
            row['nick_name'] as String,
            row['owner_id'] as int),
        arguments: [id],
        queryableName: 'dog',
        isView: false);
  }

  @override
  Future<void> insertPerson(Person person) async {
    await _personInsertionAdapter.insert(person, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertPersons(List<Person> persons) async {
    await _personInsertionAdapter.insertList(persons, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertPersonWithReturn(Person person) {
    return _personInsertionAdapter.insertAndReturnId(
        person, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertPersonsWithReturn(List<Person> persons) {
    return _personInsertionAdapter.insertListAndReturnIds(
        persons, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePerson(Person person) async {
    await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePersons(List<Person> persons) async {
    await _personUpdateAdapter.updateList(persons, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePersonWithReturn(Person person) {
    return _personUpdateAdapter.updateAndReturnChangedRows(
        person, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePersonsWithReturn(List<Person> persons) {
    return _personUpdateAdapter.updateListAndReturnChangedRows(
        persons, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePerson(Person person) async {
    await _personDeletionAdapter.delete(person);
  }

  @override
  Future<void> deletePersons(List<Person> person) async {
    await _personDeletionAdapter.deleteList(person);
  }

  @override
  Future<int> deletePersonWithReturn(Person person) {
    return _personDeletionAdapter.deleteAndReturnChangedRows(person);
  }

  @override
  Future<int> deletePersonsWithReturn(List<Person> persons) {
    return _personDeletionAdapter.deleteListAndReturnChangedRows(persons);
  }

  @override
  Future<void> replacePersons(List<Person> persons) async {
    if (database is sqflite.Transaction) {
      await super.replacePersons(persons);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$TestDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.personDao.replacePersons(persons);
      });
    }
  }

  @override
  Future<List<Person>> replacePersonsAndReturn(List<Person> persons) async {
    if (database is sqflite.Transaction) {
      return super.replacePersonsAndReturn(persons);
    } else {
      return (database as sqflite.Database)
          .transaction<List<Person>>((transaction) async {
        final transactionDatabase = _$TestDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.personDao.replacePersonsAndReturn(persons);
      });
    }
  }
}

class _$DogDao extends DogDao {
  _$DogDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _dogInsertionAdapter = InsertionAdapter(
            database,
            'dog',
            (Dog item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'nick_name': item.nickName,
                  'owner_id': item.ownerId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Dog> _dogInsertionAdapter;

  @override
  Future<Dog?> findDogForPersonId(int id) async {
    return _queryAdapter.query('SELECT * FROM dog WHERE owner_id = ?1',
        mapper: (Map<String, Object?> row) => Dog(
            row['id'] as int?,
            row['name'] as String,
            row['nick_name'] as String,
            row['owner_id'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Dog>> findAllDogs() async {
    return _queryAdapter.queryList('SELECT * FROM dog',
        mapper: (Map<String, Object?> row) => Dog(
            row['id'] as int?,
            row['name'] as String,
            row['nick_name'] as String,
            row['owner_id'] as int));
  }

  @override
  Future<void> insertDog(Dog dog) async {
    await _dogInsertionAdapter.insert(dog, OnConflictStrategy.abort);
  }
}
