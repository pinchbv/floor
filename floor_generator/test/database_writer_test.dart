import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  useDartfmt();

  test('open database for simple entity', () async {
    final actual = await _generateDatabase('''
      @entity
      class Person {
        @PrimaryKey()
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    expect(actual, equalsDart(r'''
      Future<TestDatabase> _$open([List<Migration> migrations = const []]) async {
        final database = _$TestDatabase();
        database.database = await database.open(migrations);
        return database;
      }
      
      class _$TestDatabase extends TestDatabase {
        @override
        Future<sqflite.Database> open(List<Migration> migrations) async {
          final path = join(await sqflite.getDatabasesPath(), 'testdatabase.db');
      
          return sqflite.openDatabase(
            path,
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (database, startVersion, endVersion) async {
              runMigrations(database, startVersion, endVersion, migrations);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER PRIMARY KEY NOT NULL, `name` TEXT)');
            },
          );
        }
      }      
    '''));
  });

  test('open database for complex entity', () async {
    final actual = await _generateDatabase('''
      @Entity(tableName: 'custom_table_name')
      class Person {
        @PrimaryKey(autoGenerate: true)
        final int id;
      
        @ColumnInfo(name: 'custom_name', nullable: false)
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    expect(actual, equalsDart(r'''
      Future<TestDatabase> _$open([List<Migration> migrations = const []]) async {
        final database = _$TestDatabase();
        database.database = await database.open(migrations);
        return database;
      }
      
      class _$TestDatabase extends TestDatabase {
        @override
        Future<sqflite.Database> open(List<Migration> migrations) async {
          final path = join(await sqflite.getDatabasesPath(), 'testdatabase.db');
      
          return sqflite.openDatabase(
            path,
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (database, startVersion, endVersion) async {
              runMigrations(database, startVersion, endVersion, migrations);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `custom_table_name` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `custom_name` TEXT NOT NULL)');
            },
          );
        }
      }      
    '''));
  });

  test('exception when no entitiy defined', () async {
    expect(
      () => _generateDatabase(''),
      throwsInvalidGenerationSourceError,
    );
  });
}

Future<Spec> _generateDatabase(final String entity) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @Database(version: 1)
      abstract class TestDatabase extends FloorDatabase {
        static Future<TestDatabase> openDatabase() async => _\$open();
      }
      
      $entity
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return DatabaseWriter(library).write();
}

final throwsInvalidGenerationSourceError =
    throwsA(const TypeMatcher<InvalidGenerationSourceError>());
