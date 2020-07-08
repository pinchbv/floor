import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/writer/deletion_method_writer.dart';
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
  final dao = await createDaoMethod(methodSignature);
  return dao.deletionMethods.first;
}
