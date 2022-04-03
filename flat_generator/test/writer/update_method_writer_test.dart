import 'package:code_builder/code_builder.dart';
import 'package:flat_generator/value_object/update_method.dart';
import 'package:flat_generator/writer/update_method_writer.dart';
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
          await _personUpdateAdapter.update(person, OnConflictStrategy.abort);
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
          await _personUpdateAdapter.updateList(persons, OnConflictStrategy.abort);
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
          return _personUpdateAdapter.updateAndReturnChangedRows(person, OnConflictStrategy.abort);
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
          return _personUpdateAdapter.updateListAndReturnChangedRows(persons, OnConflictStrategy.abort);
        }
      '''));
    });
  });

  test('update person on conflict fail', () async {
    final updateMethod = await _createUpdateMethod('''
        @Update(onConflict: OnConflictStrategy.fail)
        Future<void> updatePerson(Person person);
      ''');

    final actual = UpdateMethodWriter(updateMethod).write();

    expect(actual, equalsDart(r'''
        @override
        Future<void> updatePerson(Person person) async {
          await _personUpdateAdapter.update(person, OnConflictStrategy.fail);
        }
      '''));
  });
}

Future<UpdateMethod> _createUpdateMethod(
  final String methodSignature,
) async {
  final dao = await createDao(methodSignature);
  return dao.updateMethods.first;
}
