import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/writer/writer.dart';

/// Takes care of generating the database implementation.
class DatabaseWriter implements Writer {
  final Database database;

  DatabaseWriter(final this.database);

  @override
  Class write() {
    return _generateDatabaseImplementation(database);
  }

  Class _generateDatabaseImplementation(final Database database) {
    final databaseName = database.name;

    return Class((builder) {
      builder
        ..name = '_\$$databaseName'
        ..extend = refer(databaseName)
        ..methods.add(_generateOpenMethod(database))
        ..methods.add(_generateCreateMethod(database))
        ..methods.addAll(_generateDaoGetters(database))
        ..fields.addAll(_generateDaoInstances(database))
        ..constructors.add(_generateConstructor());
    });
  }

  Constructor _generateConstructor() {
    return Constructor((builder) {
      final parameter = Parameter((builder) => builder
        ..name = 'listener'
        ..type = refer('StreamController<String>?'));

      builder
        ..body = const Code(
          'changeListener = listener ?? StreamController<String>.broadcast();',
        )
        ..optionalParameters.add(parameter);
    });
  }

  List<Method> _generateDaoGetters(final Database database) {
    return database.daoGetters.map((daoGetter) {
      final daoGetterName = daoGetter.name;
      final daoTypeName = daoGetter.dao.classElement.displayName;

      return Method((builder) => builder
        ..annotations.add(overrideAnnotationExpression)
        ..type = MethodType.getter
        ..returns = refer(daoTypeName)
        ..name = daoGetterName
        ..body = Code(
            'return _${daoGetterName}Instance ??= _\$$daoTypeName(database, changeListener);'));
    }).toList();
  }

  List<Field> _generateDaoInstances(final Database database) {
    return database.daoGetters.map((daoGetter) {
      final daoGetterName = daoGetter.name;
      final daoTypeName = daoGetter.dao.classElement.displayName;

      return Field((builder) => builder
        ..type = refer('$daoTypeName?')
        ..name = '_${daoGetterName}Instance');
    }).toList();
  }

  Method _generateCreateMethod(final Database database) {
    final databaseParameter = Parameter((builder) => builder
      ..name = 'database'
      ..type = refer('sqflite.Database'));

    final createTableStatements = _generateCreateTableSqlStatements(
            database.entities)
        .map((statement) => 'await database.execute(${statement.toLiteral()});')
        .join('\n');

    final createIndexStatements = database.entities
        .map((entity) => entity.indices.map((index) => index.createQuery()))
        .expand((statements) => statements)
        .map((statement) => 'await database.execute(${statement.toLiteral()});')
        .join('\n');

    final createViewStatements = database.views
        .map((view) => view.getCreateViewStatement().toLiteral())
        .map((statement) => 'await database.execute($statement);')
        .join('\n');

    return Method((builder) => builder
      ..name = '_create'
      ..returns = refer('Future<void>')
      ..requiredParameters.add(databaseParameter)
      ..modifier = MethodModifier.async
      ..body = Code('''
          $createTableStatements
          $createIndexStatements
          $createViewStatements
          '''));
  }

  Method _generateOpenMethod(final Database database) {
    final pathParameter = Parameter((builder) => builder
      ..name = 'path'
      ..type = refer('String'));
    final migrationsParameter = Parameter((builder) => builder
      ..name = 'migrations'
      ..type = refer('List<Migration>'));
    final callbackParameter = Parameter((builder) => builder
      ..name = 'callback'
      ..type = refer('Callback?'));

    String body;

    if (database.fallbackToDestructiveMigration) {
      body = '''
        bool shouldDeleteDatabase = false;

        final databaseOptions = sqflite.OpenDatabaseOptions(
          version: ${database.version},
          onConfigure: (database) async {
            await database.execute('PRAGMA foreign_keys = ON');
            await callback?.onConfigure?.call(database);
          },
          onOpen: (database) async {
            await callback?.onOpen?.call(database);
          },
          onUpgrade: (database, startVersion, endVersion) async {
            try {
              await MigrationAdapter.runMigrations(
                database,
                startVersion,
                endVersion,
                migrations,
              );
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            } on Exception catch (e) {
              await callback?.onDestructiveUpgrade?.call(database, startVersion, endVersion, e);
              shouldDeleteDatabase = true;
            }
          },
          onDowngrade: (database, startVersion, endVersion) async {
            await callback?.onDestructiveDowngrade?.call(database, startVersion, endVersion);
            shouldDeleteDatabase = true;
          },
          onCreate: (database, version) async {
            await _create(database);
            await callback?.onCreate?.call(database, version);
          },
        );

        final database = await sqfliteDatabaseFactory.openDatabase(path,
            options: databaseOptions);

        if (shouldDeleteDatabase) {
          await database.close();
          await sqfliteDatabaseFactory.deleteDatabase(path);
          return sqfliteDatabaseFactory.openDatabase(path,
              options: databaseOptions);
        } else {
          return database;
        }
      ''';
    } else {
      body = '''
          final databaseOptions = sqflite.OpenDatabaseOptions(
            version: ${database.version},
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
              await callback?.onConfigure?.call(database);
            },
            onOpen: (database) async {
              await callback?.onOpen?.call(database);
            },
            onUpgrade: (database, startVersion, endVersion) async {
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
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
          ''';
    }

    return Method((builder) => builder
      ..name = 'open'
      ..returns = refer('Future<sqflite.Database>')
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll([pathParameter, migrationsParameter])
      ..optionalParameters.add(callbackParameter)
      ..body = Code(body));
  }

  List<String> _generateCreateTableSqlStatements(final List<Entity> entities) {
    return entities.map((entity) => entity.getCreateTableStatement()).toList();
  }
}
