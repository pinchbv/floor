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

    return Class((builder) => builder
      ..name = '_\$$databaseName'
      ..extend = refer(databaseName)
      ..methods.add(_generateOpenMethod(database))
      ..methods.add(_generateCreateMethod(database))
      ..methods.add(_generateDropAll())
      ..methods.add(_generateDrop())
      ..methods.add(_generateMigrate(database))
      ..methods.addAll(_generateDaoGetters(database))
      ..fields.addAll(_generateDaoInstances(database))
      ..constructors.add(_generateConstructor()));
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

  Method _generateMigrate(final Database database) {
    final databaseParameter = Parameter((builder) => builder
      ..name = 'database'
      ..type = refer('sqflite.Database'));

    final migrationsParameter = Parameter((builder) => builder
      ..name = 'migrations'
      ..type = refer('List<Migration>'));

    final startVersionParameter = Parameter((builder) => builder
      ..name = 'startVersion'
      ..type = refer('int'));

    final endVersionParameter = Parameter((builder) => builder
      ..name = 'endVersion'
      ..type = refer('int'));

    final callbackParameter = Parameter((builder) => builder
      ..name = 'callback'
      ..type = refer('Callback?'));

    final String code;

    if (database.fallbackToDestructiveMigration) {
      code = '''
          try {
            await MigrationAdapter.runMigrations(
              database, 
              startVersion,
              endVersion,
              migrations,
            );
          } on Exception catch (exception) {
            await callback?.onDestructiveUpgrade?.call(database, startVersion, endVersion, exception);
            await _dropAll(database);
            await _create(database);
          }
          ''';
    } else {
      code = '''
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
          ''';
    }

    return Method((builder) => builder
      ..name = '_migrate'
      ..returns = refer('Future<void>')
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll([
        databaseParameter,
        migrationsParameter,
        startVersionParameter,
        endVersionParameter,
        callbackParameter,
      ])
      ..body = Code(code));
  }

  Method _generateDropAll() {
    final databaseParameter = Parameter((builder) => builder
      ..name = 'database'
      ..type = refer('sqflite.Database'));

    return Method((builder) => builder
      ..name = '_dropAll'
      ..returns = refer('Future<void>')
      ..requiredParameters.add(databaseParameter)
      ..modifier = MethodModifier.async
      ..body = const Code('''
          await _drop(database, 'table');
          await _drop(database, 'view');
          '''));
  }

  Method _generateDrop() {
    final databaseParameter = Parameter((builder) => builder
      ..name = 'database'
      ..type = refer('sqflite.Database'));

    final type = Parameter((builder) => builder
      ..name = 'type'
      ..type = refer('String'));

    return Method((builder) => builder
      ..name = '_drop'
      ..returns = refer('Future<void>')
      ..modifier = MethodModifier.async
      ..requiredParameters.add(databaseParameter)
      ..requiredParameters.add(type)
      ..body = const Code('''
          final names = await database
            .rawQuery('SELECT name FROM sqlite_master WHERE type = ?', [type]);

          for (final name in names) {
            await database.rawQuery('DROP \$type \${name['name']}');
          }
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

    return Method((builder) => builder
      ..name = 'open'
      ..returns = refer('Future<sqflite.Database>')
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll([pathParameter, migrationsParameter])
      ..optionalParameters.add(callbackParameter)
      ..body = Code('''
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
              await _migrate(database, migrations, startVersion, endVersion, callback);
              await callback?.onUpgrade?.call(database, startVersion, endVersion);
            },
            onCreate: (database, version) async {
              await _create(database);
              await callback?.onCreate?.call(database, version);
            },
          );
          return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
          '''));
  }

  List<String> _generateCreateTableSqlStatements(final List<Entity> entities) {
    return entities.map((entity) => entity.getCreateTableStatement()).toList();
  }
}
