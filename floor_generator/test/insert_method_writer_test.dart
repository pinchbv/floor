import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/writer/change_method_writer.dart';
import 'package:floor_generator/writer/insert_method_body_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  useDartfmt();

  group('void return insert', () {
    test('insert single person', () async {
      final actual = await _generateInsertMethod('''
        @insert
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('insert person list', () async {
      final actual = await _generateInsertMethod('''
        @insert
        Future<void> insertPersons(List<Person> persons);
      ''');

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
      final actual = await _generateInsertMethod('''
        @insert
        Future<int> insertPersonWithReturn(Person person);
      ''');

      expect(actual, equalsDart('''
        @override
        Future<int> insertPersonWithReturn(Person person) {
          return _personInsertionAdapter.insertAndReturnId(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('insert person list', () async {
      final actual = await _generateInsertMethod('''
        @insert
        Future<List<int>> insertPersonsWithReturn(List<Person> persons);
      ''');

      expect(actual, equalsDart('''
        @override
        Future<List<int>> insertPersonsWithReturn(List<Person> persons) {
          return _personInsertionAdapter.insertListAndReturnIds(persons, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });
  });

  group('on conflic strategy', () {
    test('insert method on conflict default (abort)', () async {
      final actual = await _generateInsertMethod('''
        @insert
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
        }
       '''));
    });

    test('insert method on conflict replace', () async {
      final actual = await _generateInsertMethod('''
        @Insert(onConflict: OnConflictStrategy.REPLACE)
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.replace);
        }
      '''));
    });

    test('insert method on conflict rollback', () async {
      final actual = await _generateInsertMethod('''
        @Insert(onConflict: OnConflictStrategy.ROLLBACK)
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
         @override
         Future<void> insertPerson(Person person) async {
           await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.rollback);
         }
      '''));
    });

    test('insert method on conflict abort', () async {
      final actual = await _generateInsertMethod('''
        @Insert(onConflict: OnConflictStrategy.ABORT)
        Future<void> insertPerson(Person person);
     ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.abort);
        }
      '''));
    });

    test('insert method on conflict fail', () async {
      final actual = await _generateInsertMethod('''
        @Insert(onConflict: OnConflictStrategy.FAIL)
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
          await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.fail);
        }
      '''));
    });

    test('insert method on conflict ignore', () async {
      final actual = await _generateInsertMethod('''
        @Insert(onConflict: OnConflictStrategy.IGNORE)
        Future<void> insertPerson(Person person);
      ''');

      expect(actual, equalsDart(r'''
        @override
        Future<void> insertPerson(Person person) async {
        await _personInsertionAdapter.insert(person, sqflite.ConflictAlgorithm.ignore);
        }
      '''));
    });
  });
}

Future<Method> _generateInsertMethod(final String methodSignature) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
      
        $methodSignature
      }
      
      @Entity(tableName: 'person')
      class Person {
        @PrimaryKey()
        final int id;
      
        @ColumnInfo(name: 'custom_name', nullable: false)
        final String name;
      
        Person(this.id, this.name);
      }
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  final daoClass = library.classes
      .where((clazz) => clazz.isAbstract && clazz.metadata.any(isDaoAnnotation))
      .first;

  final dao = Dao(daoClass, 'personDao', 'TestDatabase');
  final insertMethod = dao.insertMethods.first;
  final writer = InsertMethodBodyWriter(library, insertMethod);
  return ChangeMethodWriter(library, insertMethod, writer).write();
}
