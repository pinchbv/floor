import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/writer/deletion_method_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  group('void return deletion', () {
    test('delete person', () async {
      final deletionMethod = await _createDeletionMethod('''
        @delete
        Future<void> deletePerson(Person person);
      ''');

      final actual = DeletionMethodWriter(deletionMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<void> deletePerson(Person person) async {
          await _personDeletionAdapter.delete(person);
        }
      '''));
    });

    test('delete multiple persons', () async {
      final deletionMethod = await _createDeletionMethod('''
        @delete
        Future<void> deletePersons(List<Person> persons);
      ''');

      final actual = DeletionMethodWriter(deletionMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<void> deletePersons(List<Person> persons) async {
          await _personDeletionAdapter.deleteList(persons);
        }
      '''));
    });
  });

  group('int return deletion', () {
    test('delete person and return changed rows count', () async {
      final deletionMethod = await _createDeletionMethod('''
        @delete
        Future<int> deletePerson(Person person);
      ''');

      final actual = DeletionMethodWriter(deletionMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<int> deletePerson(Person person) {
          return _personDeletionAdapter.deleteAndReturnChangedRows(person);
        }
      '''));
    });

    test('delete multiple persons and return changed rows count', () async {
      final deletionMethod = await _createDeletionMethod('''
        @delete
        Future<int> deletePersons(List<Person> persons);
      ''');

      final actual = DeletionMethodWriter(deletionMethod).write();

      expect(actual, equalsDart(r'''
        @override
        Future<int> deletePersons(List<Person> persons) {
          return _personDeletionAdapter.deleteListAndReturnChangedRows(persons);
        }
      '''));
    });
  });
}

Future<DeletionMethod> _createDeletionMethod(
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
  return dao.deletionMethods.first;
}
