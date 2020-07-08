import 'package:code_builder/code_builder.dart';

import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('create DAO no stream query', () async {
    final dao = await createDao('''
        @dao
        abstract class PersonDao {
          @Query('SELECT * FROM person')
          Future<List<Person>> findAllPersons();
          
          @insert
          Future<void> insertPerson(Person person);
          
          @update
          Future<void> updatePerson(Person person);
          
          @delete
          Future<void> deletePerson(Person person);
        }
      ''');

    final actual = DaoWriter(dao, dao.streamEntities.toSet()).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(this.database, this.changeListener)
              : _queryAdapter = QueryAdapter(database),
                _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name}),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name}),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name});
        
          final sqflite.DatabaseExecutor database;
        
          final StreamController<String> changeListener;
        
          final QueryAdapter _queryAdapter;
        
          static final _personMapper = (Map<String, dynamic> row) =>
              Person(row['id'] as int, row['name'] as String);
        
          final InsertionAdapter<Person> _personInsertionAdapter;
        
          final UpdateAdapter<Person> _personUpdateAdapter;
        
          final DeletionAdapter<Person> _personDeletionAdapter;
        
          @override
          Future<List<Person>> findAllPersons() async {
            return _queryAdapter.queryList('SELECT * FROM person', mapper: _personMapper);
          }
          
          @override
          Future<void> insertPerson(Person person) async {
            await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> deletePerson(Person person) async {
            await _personDeletionAdapter.delete(person);
          }
        }
      '''));
  });

  test('create DAO stream query', () async {
    final dao = await createDao('''
        @dao
        abstract class PersonDao {
          @Query('SELECT * FROM person')
          Stream<List<Person>> findAllPersonsAsStream();
          
          @insert
          Future<void> insertPerson(Person person);
          
          @update
          Future<void> updatePerson(Person person);
          
          @delete
          Future<void> deletePerson(Person person);
        }
      ''');

    final actual = DaoWriter(dao, dao.streamEntities.toSet()).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(this.database, this.changeListener)
              : _queryAdapter = QueryAdapter(database, changeListener),
                _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener);
        
          final sqflite.DatabaseExecutor database;
        
          final StreamController<String> changeListener;
        
          final QueryAdapter _queryAdapter;
        
          static final _personMapper = (Map<String, dynamic> row) =>
              Person(row['id'] as int, row['name'] as String);
        
          final InsertionAdapter<Person> _personInsertionAdapter;
        
          final UpdateAdapter<Person> _personUpdateAdapter;
        
          final DeletionAdapter<Person> _personDeletionAdapter;
        
          @override
          Stream<List<Person>> findAllPersonsAsStream() {
            return _queryAdapter.queryListStream('SELECT * FROM person', mapper: _personMapper, dependencies: {'Person'});
          }
          
          @override
          Future<void> insertPerson(Person person) async {
            await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> deletePerson(Person person) async {
            await _personDeletionAdapter.delete(person);
          }
        }
      '''));
  });

  test('create DAO aware of other entity stream query', () async {
    final dao = await createDao('''
        @dao
        abstract class PersonDao {
          @insert
          Future<void> insertPerson(Person person);
          
          @update
          Future<void> updatePerson(Person person);
          
          @delete
          Future<void> deletePerson(Person person);
        }
      ''');
    // simulate DB is aware of streamed Person and no View
    final actual = DaoWriter(dao, {dao.deletionMethods[0].entity}).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(this.database, this.changeListener)
              : _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener);
        
          final sqflite.DatabaseExecutor database;
        
          final StreamController<String> changeListener;
        
          final InsertionAdapter<Person> _personInsertionAdapter;
        
          final UpdateAdapter<Person> _personUpdateAdapter;
        
          final DeletionAdapter<Person> _personDeletionAdapter;

          @override
          Future<void> insertPerson(Person person) async {
            await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> deletePerson(Person person) async {
            await _personDeletionAdapter.delete(person);
          }
        }
      '''));
  });

  test('create DAO aware of other different entity stream query', () async {
    final dao = await createDao('''
      @dao
      abstract class PersonDao {
        @insert
        Future<void> insertPerson(Person person);
        
        @update
        Future<void> updatePerson(Person person);
        
        @delete
        Future<void> deletePerson(Person person);
      }
    ''');
    // simulate DB is aware of another streamed Entity and no View
    final otherEntity = Entity(
      null, // classElement,
      'Dog', // name,
      [], // fields,
      null, // primaryKey,
      [], // foreignKeys,
      [], // indices,
      '', // constructor
    );
    final actual = DaoWriter(dao, {otherEntity}).write();

    expect(actual, equalsDart(r'''
      class _$PersonDao extends PersonDao {
        _$PersonDao(this.database, this.changeListener)
            : _personInsertionAdapter = InsertionAdapter(
                  database,
                  'Person',
                  (Person item) =>
                      <String, dynamic>{'id': item.id, 'name': item.name}),
              _personUpdateAdapter = UpdateAdapter(
                  database,
                  'Person',
                  ['id'],
                  (Person item) =>
                      <String, dynamic>{'id': item.id, 'name': item.name}),
              _personDeletionAdapter = DeletionAdapter(
                  database,
                  'Person',
                  ['id'],
                  (Person item) =>
                      <String, dynamic>{'id': item.id, 'name': item.name});
      
        final sqflite.DatabaseExecutor database;
      
        final StreamController<String> changeListener;
      
        final InsertionAdapter<Person> _personInsertionAdapter;
      
        final UpdateAdapter<Person> _personUpdateAdapter;
      
        final DeletionAdapter<Person> _personDeletionAdapter;

        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
        }
        
        @override
        Future<void> updatePerson(Person person) async {
          await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
        }
        
        @override
        Future<void> deletePerson(Person person) async {
          await _personDeletionAdapter.delete(person);
        }
      }
    '''));
  });

/*  test('create DAO aware of other view stream query', () async {
    final dao = await _createDao('''
        @dao
        abstract class PersonDao {
          @insert
          Future<void> insertPerson(Person person);
          
          @update
          Future<void> updatePerson(Person person);
          
          @delete
          Future<void> deletePerson(Person person);
        }
      ''');
    // simulate DB is aware of no streamed entity but at least a single View
    final actual = DaoWriter(dao, {'Person'}).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(this.database, this.changeListener)
              : _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener);
        
          final sqflite.DatabaseExecutor database;
        
          final StreamController<String> changeListener;
        
          final InsertionAdapter<Person> _personInsertionAdapter;
        
          final UpdateAdapter<Person> _personUpdateAdapter;
        
          final DeletionAdapter<Person> _personDeletionAdapter;
        
          @override
          Future<void> insertPerson(Person person) async {
            await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
          }
          
          @override
          Future<void> deletePerson(Person person) async {
            await _personDeletionAdapter.delete(person);
          }
        }
      '''));
  });*/
}
