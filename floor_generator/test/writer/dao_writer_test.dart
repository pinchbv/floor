import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

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

    final actual = DaoWriter(dao).write();

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
                    'id',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name}),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    'id',
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
            await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, sqflite.ConflictAlgorithm.abort);
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

    final actual = DaoWriter(dao).write();

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
                    'id',
                    (Person item) =>
                        <String, dynamic>{'id': item.id, 'name': item.name},
                    changeListener),
                _personDeletionAdapter = DeletionAdapter(
                    database,
                    'Person',
                    'id',
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
            return _queryAdapter.queryListStream('SELECT * FROM person', tableName: 'Person', mapper: _personMapper);
          }
          
          @override
          Future<void> insertPerson(Person person) async {
            await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
          }
          
          @override
          Future<void> updatePerson(Person person) async {
            await _personUpdateAdapter.update(person, sqflite.ConflictAlgorithm.abort);
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
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  final daoClass = library.classes.firstWhere((classElement) =>
      typeChecker(annotations.dao.runtimeType)
          .hasAnnotationOfExact(classElement));

  final entities = library.classes
      .where((classElement) =>
          typeChecker(annotations.Entity).hasAnnotationOfExact(classElement))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();

  return DaoProcessor(daoClass, 'personDao', 'TestDatabase', entities)
      .process();
}
