import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/database.dart';
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
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
          final batch = database.batch();
          for (final item in persons) {
            final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
            batch.insert('person', values,
                conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
          }
          await batch.commit(noResult: true);
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          return database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
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
        Future<List<int>> insertPersonsWithReturn(List<Person> persons) async {
          final batch = database.batch();
          for (final item in persons) {
            final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
            batch.insert('person', values,
                conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
          }
          return (await batch.commit(noResult: false)).cast<int>();
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
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
           final item = person;
           final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
           await database.insert('person', values,
               conflictAlgorithm: sqflite.ConflictAlgorithm.rollback);
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.fail);
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
          final item = person;
          final values = <String, dynamic>{'id': item.id, 'custom_name': item.name};
          await database.insert('person', values,
              conflictAlgorithm: sqflite.ConflictAlgorithm.ignore);
        }
      '''));
    });
  });
}

Future<Method> _generateInsertMethod(final String methodSignature) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @Database(version: 1)
      abstract class TestDatabase extends FloorDatabase {
        static Future<TestDatabase> openDatabase() async => _\$open();
      
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

  final databaseClass = library.classes
      .where((clazz) =>
          clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation))
      .first;
  final database = Database(databaseClass);
  final insertMethod = database.insertMethods.first;

  final writer = InsertMethodBodyWriter(library, insertMethod);
  return ChangeMethodWriter(library, insertMethod, writer).write();
}
