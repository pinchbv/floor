import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/processor/database_processor.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('open database for simple entity', () async {
    final database = await _createDatabase('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = DatabaseWriter(database).write();

    expect(actual, equalsDart(r'''
      class _$TestDatabase extends TestDatabase {
        _$TestDatabase([StreamController<String> listener]) {
         changeListener = listener ?? StreamController<String>.broadcast();
        }
      
        Future<sqflite.Database> open(String name, List<Migration> migrations) async {
          final path = join(await sqflite.getDatabasesPath(), name);
      
          return sqflite.openDatabase(
            path,
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (database, startVersion, endVersion) async {
              MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);
            },
            onCreate: (database, _) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER, `name` TEXT, PRIMARY KEY (`id`))');
            },
          );
        }
      }      
    '''));
  });

  test('open database for complex entity', () async {
    final database = await _createDatabase('''
      @Entity(tableName: 'custom_table_name')
      class Person {
        @PrimaryKey(autoGenerate: true)
        final int id;
      
        @ColumnInfo(name: 'custom_name', nullable: false)
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = DatabaseWriter(database).write();

    expect(actual, equalsDart(r'''
      class _$TestDatabase extends TestDatabase {
        _$TestDatabase([StreamController<String> listener]) {
          changeListener = listener ?? StreamController<String>.broadcast();
        }
        
        Future<sqflite.Database> open(String name, List<Migration> migrations) async {
          final path = join(await sqflite.getDatabasesPath(), name);
      
          return sqflite.openDatabase(
            path,
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (database, startVersion, endVersion) async {
              MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);
            },
            onCreate: (database, _) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `custom_table_name` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `custom_name` TEXT NOT NULL)');
            },
          );
        }
      }      
    '''));
  });
}

Future<Database> _createDatabase(final String entity) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {}
      
      $entity
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return DatabaseProcessor(library.classes.first).process();
}
