import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/writer/insertion_method_writer.dart';
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
        @Insert(onConflict: OnConflictStrategy.replace)
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
  final String methodSignature,
) async {
  final dao = await createDao(methodSignature);
  return dao.insertionMethods.first;
}
