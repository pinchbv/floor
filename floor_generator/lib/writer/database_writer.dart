import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/database.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

/// Takes care of generating the database implementation.
class DatabaseWriter implements Writer {
  final LibraryReader library;

  DatabaseWriter(final this.library);

  @override
  Spec write() {
    final database = _getDatabase();
    if (database == null) return null;

    return Library((builder) => builder
      ..body.addAll([
        _generateOpenDatabaseFunction(database.name),
        _generateDatabaseImplementation(database),
      ])
      ..body.addAll(_generateDaos(database)));
  }

  Database _getDatabase() {
    final databaseClasses = library.classes.where((clazz) =>
        clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation));

    if (databaseClasses.isEmpty) {
      return null;
    } else if (databaseClasses.length > 1) {
      throw InvalidGenerationSourceError(
          'Only one database is allowed. There are too many classes annotated with @Database.');
    } else {
      return Database(databaseClasses.first);
    }
  }

  Method _generateOpenDatabaseFunction(final String databaseName) {
    final migrationsParameter = Parameter((builder) => builder
      ..name = 'migrations'
      ..type = refer('List<Migration>')
      ..defaultTo = const Code('const []'));

    return Method((builder) => builder
      ..returns = refer('Future<$databaseName>')
      ..name = '_\$open'
      ..modifier = MethodModifier.async
      ..optionalParameters.add(migrationsParameter)
      ..body = Code('''
            final database = _\$$databaseName();
            database.database = await database.open(migrations);
            return database;
            '''));
  }

  Class _generateDatabaseImplementation(final Database database) {
    final databaseName = database.name;

    return Class((builder) => builder
      ..name = '_\$$databaseName'
      ..extend = refer(databaseName)
      ..methods.add(_generateOpenMethod(database))
      ..methods.addAll(_generateDaoGetters(database))
      ..fields.addAll(_generateDaoInstances(database)));
  }

  List<Method> _generateDaoGetters(final Database database) {
    return database.getDaos(library).map((dao) {
      final daoFieldName = dao.daoFieldName;
      final daoType = dao.clazz.displayName;

      return Method((builder) => builder
        ..annotations.add(overrideAnnotationExpression)
        ..type = MethodType.getter
        ..returns = refer(daoType)
        ..name = daoFieldName
        ..body = Code(
            'return _${daoFieldName}Instance ??= _\$$daoType(database, changeListener);'));
    }).toList();
  }

  List<Field> _generateDaoInstances(final Database database) {
    return database.getDaos(library).map((dao) {
      final daoFieldName = dao.daoFieldName;
      final daoType = dao.clazz.displayName;

      return Field((builder) => builder
        ..type = refer(daoType)
        ..name = '_${daoFieldName}Instance');
    }).toList();
  }

  Method _generateOpenMethod(final Database database) {
    final createTableStatements =
        _generateCreateTableSqlStatements(database.getEntities(library))
            .map((statement) => 'await database.execute($statement);')
            .join('\n');

    if (createTableStatements.isEmpty) {
      throw InvalidGenerationSourceError(
          'There are no entities defined. Use the @Entity annotation on persistent classes to do so.');
    }

    final migrationsParameter = Parameter((builder) => builder
      ..name = 'migrations'
      ..type = refer('List<Migration>'));

    return Method((builder) => builder
      ..name = 'open'
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer('Future<sqflite.Database>')
      ..modifier = MethodModifier.async
      ..requiredParameters.add(migrationsParameter)
      ..body = Code('''
          final path = join(await sqflite.getDatabasesPath(), '${database.name.toLowerCase()}.db');

          return sqflite.openDatabase(
            path,
            version: ${database.version},
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onUpgrade: (database, startVersion, endVersion) async {
              MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);
            },
            onCreate: (database, version) async {
              $createTableStatements
            },
          );
          '''));
  }

  List<String> _generateCreateTableSqlStatements(final List<Entity> entities) {
    return entities
        .map((entity) => entity.getCreateTableStatement(library))
        .toList();
  }

  List<Class> _generateDaos(final Database database) {
    return database
        .getDaos(library)
        .map((dao) => DaoWriter(library, dao).write())
        .toList();
  }
}
