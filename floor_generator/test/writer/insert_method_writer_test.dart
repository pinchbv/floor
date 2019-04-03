import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/writer/insertion_method_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  group('void return insert', () {
    test('insert single person', () async {
      final insertionMethod = await _createInsertionMethod('''
        @insert
        Future<void> insertPerson(Person person);
      ''');

      final actual = InsertionMethodWriter(insertionMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('insert person list', () async {
      final insertionMethod = await _createInsertionMethod('''
        @insert
        Future<void> insertPersons(List<Person> persons);
      ''');

      final actual = InsertionMethodWriter(insertionMethod).write();

      expect(actual, equalsDart('''
        @override
        Future<void> insertPersons(List<Person> persons) async {
          await _personInsertionAdapter.insertList(persons, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });
  });

  group('int return insert', () {
    test('insert single person', () async {
      final insertionMethod = await _createInsertionMethod('''
        @insert
        Future<int> insertPersonWithReturn(Person person);
      ''');

      final actual = InsertionMethodWriter(insertionMethod).write();

      expect(actual, equalsDart('''
        @override
        Future<int> insertPersonWithReturn(Person person) {
          return _personInsertionAdapter.insertAndReturnId(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('insert person list', () async {
      final insertionMethod = await _createInsertionMethod('''
        @insert
        Future<List<int>> insertPersonsWithReturn(List<Person> persons);
      ''');

      final actual = InsertionMethodWriter(insertionMethod).write();

      expect(actual, equalsDart('''
        @override
        Future<List<int>> insertPersonsWithReturn(List<Person> persons) {
          return _personInsertionAdapter.insertListAndReturnIds(persons, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });
  });

  test('insert method on conflict replace', () async {
    final insertionMethod = await _createInsertionMethod('''
        @Insert(onConflict: OnConflictStrategy.REPLACE)
        Future<void> insertPerson(Person person);
      ''');

    final actual = InsertionMethodWriter(insertionMethod).write();

    expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.replace);
        }
      '''));
  });
}

Future<InsertionMethod> _createInsertionMethod(
    final String methodSignature) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
      
        $methodSignature
      }
      
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

  final dao =
      DaoProcessor(daoClass, 'personDao', 'TestDatabase', entities).process();
  return dao.insertionMethods.first;
}
