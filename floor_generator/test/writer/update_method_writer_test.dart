import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/writer/update_method_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  group('void return update', () {
    test('update person', () async {
      final updateMethod = await _createUpdateMethod('''
        @update
        Future<void> updatePerson(Person person);
      ''');

      final actual = UpdateMethodWriter(updateMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<void> updatePerson(Person person) async {
          await _personUpdateAdapter.update(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('update multiple persons', () async {
      final updateMethod = await _createUpdateMethod('''
        @update
        Future<void> updatePersons(List<Person> persons);
      ''');

      final actual = UpdateMethodWriter(updateMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<void> updatePersons(List<Person> persons) async {
          await _personUpdateAdapter.updateList(persons, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });
  });

  group('int return update', () {
    test('update person and return changed rows count', () async {
      final updateMethod = await _createUpdateMethod('''
        @update
        Future<int> updatePerson(Person person);
      ''');

      final actual = UpdateMethodWriter(updateMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<int> updatePerson(Person person) {
          return _personUpdateAdapter.updateAndReturnChangedRows(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('update multiple persons and return changed rows count', () async {
      final updateMethod = await _createUpdateMethod('''
        @update
        Future<int> updatePersons(List<Person> persons);
      ''');

      final actual = UpdateMethodWriter(updateMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<int> updatePersons(List<Person> persons) {
          return _personUpdateAdapter.updateListAndReturnChangedRows(persons, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });
  });

  test('update person on conflict fail', () async {
    final updateMethod = await _createUpdateMethod('''
        @Update(onConflict: OnConflictStrategy.FAIL)
        Future<void> updatePerson(Person person);
      ''');

    final actual = UpdateMethodWriter(updateMethod).write();

    expect(actual, equalsDart(r'''
        @override
        Future<void> updatePerson(Person person) async {
          await _personUpdateAdapter.update(person, sqflite.ConflictAlgorithm.fail);
        }
      '''));
  });
}

Future<UpdateMethod> _createUpdateMethod(
  final String methodSignature,
) async {
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
  return dao.updateMethods.first;
}
