// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorTestDatabase {
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

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

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
        ? join(await sqflite.getDatabasesPath(), name)
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
  _$TestDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PersonDao _personDaoInstance;

  DogDao _dogDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 2,
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
            'CREATE TABLE IF NOT EXISTS `person` (`id` INTEGER, `custom_name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `dog` (`id` INTEGER, `name` TEXT, `nick_name` TEXT, `owner_id` INTEGER, FOREIGN KEY (`owner_id`) REFERENCES `person` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_person_custom_name` ON `person` (`custom_name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
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
  _$PersonDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'person',
            (Person item) =>
                <String, dynamic>{'id': item.id, 'custom_name': item.name},
            changeListener),
        _personUpdateAdapter = UpdateAdapter(
            database,
            'person',
            ['id'],
            (Person item) =>
                <String, dynamic>{'id': item.id, 'custom_name': item.name},
            changeListener),
        _personDeletionAdapter = DeletionAdapter(
            database,
            'person',
            ['id'],
            (Person item) =>
                <String, dynamic>{'id': item.id, 'custom_name': item.name},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _personMapper = (Map<String, dynamic> row) =>
      Person(row['id'] as int, row['custom_name'] as String);

  final InsertionAdapter<Person> _personInsertionAdapter;

  final UpdateAdapter<Person> _personUpdateAdapter;

  final DeletionAdapter<Person> _personDeletionAdapter;

  @override
  Future<List<Person>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM person',
        mapper: _personMapper);
  }

  @override
  Stream<List<Person>> findAllPersonsAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM person',
        tableName: 'person', mapper: _personMapper);
  }

  @override
  Future<Person> findPersonById(int id) async {
    return _queryAdapter.query('SELECT * FROM person WHERE id = ?',
        arguments: <dynamic>[id], mapper: _personMapper);
  }

  @override
  Stream<Person> findPersonByIdAsStream(int id) {
    return _queryAdapter.queryStream('SELECT * FROM person WHERE id = ?',
        arguments: <dynamic>[id], tableName: 'person', mapper: _personMapper);
  }

  @override
  Future<Person> findPersonByIdAndName(int id, String name) async {
    return _queryAdapter.query(
        'SELECT * FROM person WHERE id = ? AND custom_name = ?',
        arguments: <dynamic>[id, name],
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> findPersonsWithIds(List<int> ids) async {
    final valueList1 = ids.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE id IN ($valueList1)',
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> findPersonsWithNames(List<String> names) async {
    final valueList1 = names.map((value) => "'$value'").join(', ');
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name IN ($valueList1)',
        mapper: _personMapper);
  }

  @override
  Future<List<Person>> findPersonsWithNamesLike(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM person WHERE custom_name LIKE ?',
        arguments: <dynamic>[name],
        mapper: _personMapper);
  }

  @override
  Future<void> deleteAllPersons() async {
    await _queryAdapter.queryNoReturn('DELETE FROM person');
  }

  @override
  Future<void> insertPerson(Person person) async {
    await _personInsertionAdapter.insert(
        person, sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<void> insertPersons(List<Person> persons) async {
    await _personInsertionAdapter.insertList(
        persons, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> insertPersonWithReturn(Person person) {
    return _personInsertionAdapter.insertAndReturnId(
        person, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<List<int>> insertPersonsWithReturn(List<Person> persons) {
    return _personInsertionAdapter.insertListAndReturnIds(
        persons, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updatePerson(Person person) async {
    await _personUpdateAdapter.update(person, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updatePersons(List<Person> persons) async {
    await _personUpdateAdapter.updateList(
        persons, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updatePersonWithReturn(Person person) {
    return _personUpdateAdapter.updateAndReturnChangedRows(
        person, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updatePersonsWithReturn(List<Person> persons) {
    return _personUpdateAdapter.updateListAndReturnChangedRows(
        persons, sqflite.ConflictAlgorithm.abort);
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
}

class _$DogDao extends DogDao {
  _$DogDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _dogInsertionAdapter = InsertionAdapter(
            database,
            'dog',
            (Dog item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'nick_name': item.nickName,
                  'owner_id': item.ownerId
                }),
        _dogUpdateAdapter = UpdateAdapter(
            database,
            'dog',
            ['id'],
            (Dog item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'nick_name': item.nickName,
                  'owner_id': item.ownerId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _dogMapper = (Map<String, dynamic> row) => Dog(
      row['id'] as int,
      row['name'] as String,
      row['nick_name'] as String,
      row['owner_id'] as int);

  final InsertionAdapter<Dog> _dogInsertionAdapter;

  final UpdateAdapter<Dog> _dogUpdateAdapter;

  @override
  Future<Dog> findDogForPersonId(int id) async {
    return _queryAdapter.query('SELECT * FROM dog WHERE owner_id = ?',
        arguments: <dynamic>[id], mapper: _dogMapper);
  }

  @override
  Future<List<Dog>> findAllDogs() async {
    return _queryAdapter.queryList('SELECT * FROM dog', mapper: _dogMapper);
  }

  @override
  Future<Dog> findDogForPicture(Uint8List pic) async {
    return _queryAdapter.query('SELECT * FROM dog WHERE picture = ?',
        arguments: <dynamic>[pic], mapper: _dogMapper);
  }

  @override
  Future<void> insertDog(Dog dog) async {
    await _dogInsertionAdapter.insert(dog, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateDog(Dog dog) async {
    await _dogUpdateAdapter.update(dog, sqflite.ConflictAlgorithm.abort);
  }
}
