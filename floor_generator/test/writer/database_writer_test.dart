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
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {}
      
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
              await _migrate(
                  database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }

        Future<void> _create(sqflite.Database database) async {
          await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        }

        Future<void> _migrate(sqflite.Database database, List<Migration> migrations,
            int startVersion, int endVersion, Callback? callback) async {
          try {
            await MigrationAdapter.runMigrations(
              database,
              startVersion,
              endVersion,
              migrations,
            );
          } on MissingMigrationException catch (_) {
            throw StateError(
              'There is no migration supplied to update the database to the current version.'
              ' Aborting the migration.',
            );
          }
        }
      }      
    '''));
  });

  test('open database for simple entity using fallback migration', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person], fallbackToDestructiveMigration: true)
      abstract class TestDatabase extends FloorDatabase {}
      
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
              await _migrate(
                  database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }

        Future<void> _create(sqflite.Database database) async {
          await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        }

        Future<void> _migrate(sqflite.Database database, List<Migration> migrations,
            int startVersion, int endVersion, Callback? callback) async {
          try {
            await MigrationAdapter.runMigrations(
              database,
              startVersion,
              endVersion,
              migrations,
            );
          } on Exception catch (exception) {
            await callback?.onDestructiveUpgrade
                ?.call(database, startVersion, endVersion, exception);
            await _dropAll(database);
            await _create(database);
          }
        }

        Future<void> _dropAll(sqflite.Database database) async {
          await _drop(database, 'table');
          await _drop(database, 'view');
        }

        Future<void> _drop(sqflite.Database database, String type) async {
          final names = await database
              .rawQuery('SELECT name FROM sqlite_master WHERE type = ?', [type]);

          for (final name in names) {
            await database.rawQuery('DROP $type ${name['name']}');
          }
        }
      }      
    '''));
  });

  test('open database with DAO', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {
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
              await _migrate(
                  database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }

        Future<void> _create(sqflite.Database database) async {
          await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        }

        Future<void> _migrate(sqflite.Database database, List<Migration> migrations,
            int startVersion, int endVersion, Callback? callback) async {
          try {
            await MigrationAdapter.runMigrations(
              database,
              startVersion,
              endVersion,
              migrations,
            );
          } on MissingMigrationException catch (_) {
            throw StateError(
              'There is no migration supplied to update the database to the current version.'
              ' Aborting the migration.',
            );
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
      abstract class TestDatabase extends FloorDatabase {}

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
              await _migrate(
                  database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }

        Future<void> _create(sqflite.Database database) async {
          await database.execute(
              'CREATE TABLE IF NOT EXISTS `custom_table_name` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `custom_name` TEXT NOT NULL)');
        }

        Future<void> _migrate(sqflite.Database database, List<Migration> migrations,
            int startVersion, int endVersion, Callback? callback) async {
          try {
            await MigrationAdapter.runMigrations(
              database,
              startVersion,
              endVersion,
              migrations,
            );
          } on MissingMigrationException catch (_) {
            throw StateError(
              'There is no migration supplied to update the database to the current version.'
              ' Aborting the migration.',
            );
          }
        }
      }
    '''));
  });

  test('open database with view', () async {
    final database = await _createDatabase('''
      @Database(version: 1, entities: [Person], views: [Name])
      abstract class TestDatabase extends FloorDatabase {}

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
              await _migrate(
                  database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
        }

        Future<void> _create(sqflite.Database database) async {
          await database.execute(
                  'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');

          await database.execute(
              'CREATE VIEW IF NOT EXISTS `names` AS SELECT custom_name as name FROM person');
        }

        Future<void> _migrate(sqflite.Database database, List<Migration> migrations,
            int startVersion, int endVersion, Callback? callback) async {
          try {
            await MigrationAdapter.runMigrations(
              database,
              startVersion,
              endVersion,
              migrations,
            );
          } on MissingMigrationException catch (_) {
            throw StateError(
              'There is no migration supplied to update the database to the current version.'
              ' Aborting the migration.',
            );
          }
        }
      }
    """));
  });
}

Future<Database> _createDatabase(final String definition) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $definition
      ''', (resolver) async {
    return LibraryReader((await resolver.findLibraryByName('test'))!);
  });

  return DatabaseProcessor(library.classes.first).process();
}
