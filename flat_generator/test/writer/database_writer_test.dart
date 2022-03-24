import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:flat_generator/processor/database_processor.dart';
import 'package:flat_generator/value_object/database.dart';
import 'package:flat_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('open database for simple entity', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FlatDatabase {}
      
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
        _$TestDatabase([StreamController<String>? listener]) {
         changeListener = listener ?? StreamController<String>.broadcast();
        }
      
        Future<sqflite.Database> open(String path, List<Migration> migrations,
            [Callback? callback]) async {
          final databaseOptions = sqflite.OpenDatabaseOptions(
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
              await callback?.onConfigure?.call(database);
            },
            onOpen: (database) async {
              await callback?.onOpen?.call(database);
            },
            onUpgrade: (database, startVersion, endVersion) async {
              await MigrationAdapter.runMigrations(
                  database, startVersion, endVersion, migrations);

              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');

              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }
        
        @override
        Future<T> transaction<T>(Future<T> Function(dynamic) action) {
          if (database is sqflite.Transaction) {
            return action(this);
          } else {
            return (database as sqflite.Database).transaction<T>((transaction) =>
                action(_$TestDatabase(changeListener)..database = transaction));
          }
        }
      }      
    '''));
  });

  test('open database with DAO', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FlatDatabase {
        TestDao get testDao;
      }
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
      
      @dao
      abstract class TestDao {
        @insert
        Future<int> insertPersonWithReturn(Person person);
      }
    ''');

    final actual = DatabaseWriter(database).write();

    expect(actual, equalsDart(r'''
      class _$TestDatabase extends TestDatabase {
        _$TestDatabase([StreamController<String>? listener]) {
          changeListener = listener ?? StreamController<String>.broadcast();
        }
        
        TestDao? _testDaoInstance;
        
        Future<sqflite.Database> open(String path, List<Migration> migrations,
            [Callback? callback]) async {
          final databaseOptions = sqflite.OpenDatabaseOptions(
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
              await callback?.onConfigure?.call(database);
            },
            onOpen: (database) async {
              await callback?.onOpen?.call(database);
            },
            onUpgrade: (database, startVersion, endVersion) async {
              await MigrationAdapter.runMigrations(
                  database, startVersion, endVersion, migrations);
      
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
      
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }
        
        @override
        Future<T> transaction<T>(Future<T> Function(dynamic) action) {
          if (database is sqflite.Transaction) {
            return action(this);
          } else {
            return (database as sqflite.Database).transaction<T>((transaction) =>
                action(_$TestDatabase(changeListener)..database = transaction));
          }
        }
      
        @override
        TestDao get testDao {
          return _testDaoInstance ??= _$TestDao(database, changeListener);
        }
      }
    '''));
  });

  test('open database for complex entity', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FlatDatabase {}
      
      @Entity(tableName: 'custom_table_name')
      class Person {
        @PrimaryKey(autoGenerate: true)
        final int? id;
      
        @ColumnInfo(name: 'custom_name')
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = DatabaseWriter(database).write();

    expect(actual, equalsDart(r'''
      class _$TestDatabase extends TestDatabase {
        _$TestDatabase([StreamController<String>? listener]) {
          changeListener = listener ?? StreamController<String>.broadcast();
        }
        
        Future<sqflite.Database> open(String path, List<Migration> migrations,
            [Callback? callback]) async {
          final databaseOptions = sqflite.OpenDatabaseOptions(
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
              await callback?.onConfigure?.call(database);
            },
            onOpen: (database) async {
              await callback?.onOpen?.call(database);
            },
            onUpgrade: (database, startVersion, endVersion) async {
              await MigrationAdapter.runMigrations(
                  database, startVersion, endVersion, migrations);

              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `custom_table_name` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `custom_name` TEXT NOT NULL)');

              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }
        
        @override
        Future<T> transaction<T>(Future<T> Function(dynamic) action) {
          if (database is sqflite.Transaction) {
            return action(this);
          } else {
            return (database as sqflite.Database).transaction<T>((transaction) =>
                action(_$TestDatabase(changeListener)..database = transaction));
          }
        }
      }      
    '''));
  });

  test('open database with view', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person], views: [Name])
      abstract class TestDatabase extends FlatDatabase {}
      
      @DatabaseView(
          'SELECT custom_name as name FROM person',
          viewName: 'names')
      class Name {
        final String name;
      
        Name(this.name);
      }
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = DatabaseWriter(database).write();

    expect(actual, equalsDart(r"""
      class _$TestDatabase extends TestDatabase {
        _$TestDatabase([StreamController<String>? listener]) {
         changeListener = listener ?? StreamController<String>.broadcast();
        }
      
        Future<sqflite.Database> open(String path, List<Migration> migrations,
            [Callback? callback]) async {
          final databaseOptions = sqflite.OpenDatabaseOptions(
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
              await callback?.onConfigure?.call(database);
            },
            onOpen: (database) async {
              await callback?.onOpen?.call(database);
            },
            onUpgrade: (database, startVersion, endVersion) async {
              await MigrationAdapter.runMigrations(
                  database, startVersion, endVersion, migrations);

              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
                  
              await database.execute(
                  'CREATE VIEW IF NOT EXISTS `names` AS SELECT custom_name as name FROM person');

              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }
        
        @override
        Future<T> transaction<T>(Future<T> Function(dynamic) action) {
          if (database is sqflite.Transaction) {
            return action(this);
          } else {
            return (database as sqflite.Database).transaction<T>((transaction) =>
                action(_$TestDatabase(changeListener)..database = transaction));
          }
        }
      }      
    """));
  });
}

Future<Database> _createDatabase(final String definition) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:flat_annotation/flat_annotation.dart';
      
      $definition
      ''', (resolver) async {
    return LibraryReader((await resolver.findLibraryByName('test'))!);
  });

  return DatabaseProcessor(library.classes.first).process();
}
