import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../fakes.dart';
import '../test_utils.dart';

void main() {
  useDartfmt();

  test('create DAO no stream query', () async {
    final dao = await _createDao('''
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

    final actual =
        DaoWriter(dao, dao.streamEntities.toSet(), dao.streamViews.isNotEmpty)
            .write();

    expect(actual, equalsDart(r'''
      class _$PersonDao extends PersonDao {
          _$PersonDao(
            this.database,
            this.changeListener,
          )   : _queryAdapter = QueryAdapter(database),
                _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name}),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name}),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name});
        
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
                    Person(row['id'] as int, row['name'] as String));
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
    final dao = await _createDao('''
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

    final actual =
        DaoWriter(dao, dao.streamEntities.toSet(), dao.streamViews.isNotEmpty)
            .write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(
            this.database,
            this.changeListener,
          ) : _queryAdapter = QueryAdapter(database, changeListener),
                _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener);
        
          final sqflite.DatabaseExecutor database;
        
          final StreamController<String> changeListener;
        
          final QueryAdapter _queryAdapter;
        
          final InsertionAdapter<Person> _personInsertionAdapter;
        
          final UpdateAdapter<Person> _personUpdateAdapter;
        
          final DeletionAdapter<Person> _personDeletionAdapter;
        
          @override
          Stream<List<Person>> findAllPersonsAsStream() {
            return _queryAdapter.queryListStream('SELECT * FROM person', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), queryableName: 'person', isView: false);
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
    // simulate DB is aware of streamed Person and no View
    final actual =
        DaoWriter(dao, {dao.deletionMethods[0].entity}, false).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(
            this.database,
            this.changeListener,
          ) : _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
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
    // simulate DB is aware of another streamed Entity and no View
    final otherEntity = Entity(
      FakeClassElement(),
      'Dog',
      [],
      PrimaryKey([], false),
      [],
      [],
      false,
      '',
      '',
      null,
    );
    final actual = DaoWriter(dao, {otherEntity}, false).write();

    expect(actual, equalsDart(r'''
      class _$PersonDao extends PersonDao {
          _$PersonDao(
            this.database,
            this.changeListener,
          ) : _personInsertionAdapter = InsertionAdapter(
                  database,
                  'Person',
                  (Person item) =>
                      <String, Object?>{'id': item.id, 'name': item.name}),
              _personUpdateAdapter = UpdateAdapter(
                  database,
                  'Person',
                  ['id'],
                  (Person item) =>
                      <String, Object?>{'id': item.id, 'name': item.name}),
              _personDeletionAdapter = DeletionAdapter(
                  database,
                  'Person',
                  ['id'],
                  (Person item) =>
                      <String, Object?>{'id': item.id, 'name': item.name});
      
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

  test('create DAO aware of other view stream query', () async {
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
    final actual = DaoWriter(dao, {}, true).write();

    expect(actual, equalsDart(r'''
        class _$PersonDao extends PersonDao {
          _$PersonDao(
            this.database,
            this.changeListener,
          ) : _personInsertionAdapter = InsertionAdapter(
                    database,
                    'Person',
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personUpdateAdapter = UpdateAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    ['id'],
                    (Person item) =>
                        <String, Object?>{'id': item.id, 'name': item.name},
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
}

Future<Dao> _createDao(final String dao) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $dao
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }

      @DatabaseView("SELECT name FROM Person")
      class Name {
        final String name;
      
        Name(this.name);
      }
      ''', (resolver) async {
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  final daoClass = library.classes.firstWhere((classElement) =>
      classElement.hasAnnotation(annotations.dao.runtimeType));

  final entities = library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, {}).process())
      .toList();

  final views = library.classes
      .where((classElement) =>
          classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement, {}).process())
      .toList();

  return DaoProcessor(
      daoClass, 'personDao', 'TestDatabase', entities, views, {}).process();
}
