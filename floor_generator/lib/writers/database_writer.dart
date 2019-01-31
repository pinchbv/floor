import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/models/column.dart';
import 'package:floor_generator/misc/sql_utils.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/models/query_method.dart';
import 'package:floor_generator/writers/query_method_writer.dart';
import 'package:floor_generator/writers/writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';

/// Takes care of generating the database implementation.
class DatabaseWriter implements Writer {
  final LibraryReader library;

  DatabaseWriter(this.library);

  @override
  Spec write() {
    final database = _getDatabaseClassElement();

    return Library((builder) => builder
      ..body.addAll([
        _generateOpenDatabaseFunction(database),
        _generateDatabaseImplementation(database)
      ]));
  }

  ClassElement _getDatabaseClassElement() {
    final databases = library.classes.where((clazz) =>
        clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation));

    if (databases.isEmpty) {
      throw InvalidGenerationSourceError(
          'No database defined. Add a @Database annotation to your abstract database class.');
    } else if (databases.length > 1) {
      throw InvalidGenerationSourceError(
          'Only one database is allowed. There are too many classes annotated with @Database.');
    } else {
      return databases.first;
    }
  }

  Method _generateOpenDatabaseFunction(ClassElement database) {
    final databaseName = database.displayName;

    return Method((builder) => builder
      ..returns = refer('Future<$databaseName>')
      ..name = '_\$open'
      ..modifier = MethodModifier.async
      ..body = Code('''
            final database = _\$$databaseName();
            database.database = await database.open();
            return database;
            '''));
  }

  Class _generateDatabaseImplementation(ClassElement database) {
    final createTableStatements =
        _generateCreateTableSqlStatements(library.classes.toList())
            .map((statement) => 'await database.execute($statement);')
            .join('\n');

    if (createTableStatements.isEmpty) {
      throw InvalidGenerationSourceError(
          'There are no entities defined. Use the @Entity annotation on model classes to do so.');
    }

    final databaseName = database.displayName;

    return Class(
      (builder) => builder
        ..name = '_\$$databaseName'
        ..extend = refer(databaseName)
        ..methods.add(
          Method((builder) => builder
            ..name = 'open'
            ..annotations.add(AnnotationExpression('override'))
            ..returns = refer('Future<sqflite.Database>')
            ..modifier = MethodModifier.async
            ..body = Code('''
            final path = join(await sqflite.getDatabasesPath(), '${databaseName.toLowerCase()}.db');

            return await sqflite.openDatabase(
              path,
              onCreate: (database, version) async {
                $createTableStatements
              },
            );
            ''')),
        )
        ..methods.addAll(_generateQueryMethods(database.methods)),
    );
  }

  List<Method> _generateQueryMethods(List<MethodElement> methods) {
    return _getQueryMethods(methods)
        .map((queryMethod) => QueryMethodWriter(library, queryMethod).write())
        .toList();
  }

  List<QueryMethod> _getQueryMethods(List<MethodElement> methods) {
    return methods
        .where((method) => method.metadata.any(isQueryAnnotation))
        .map((method) => QueryMethod(method))
        .toList();
  }

  List<String> _generateCreateTableSqlStatements(List<ClassElement> classes) {
    return classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map(_generateSql)
        .toList();
  }

  String _generateSql(ClassElement clazz) {
    final columns =
        clazz.fields.map((field) => _createColumn(field)).map((column) {
      String primaryKeyString = '';

      if (column.isPrimaryKey) {
        primaryKeyString += ' ${SqlConstants.PRIMARY_KEY}';
        if (column.autoGenerate) {
          primaryKeyString += ' ${SqlConstants.AUTOINCREMENT}';
        }
      }

      return '${column.name} ${column.type}$primaryKeyString';
    }).join(', ');

    return "'CREATE TABLE IF NOT EXISTS ${clazz.displayName} ($columns)'";
  }

  Column _createColumn(FieldElement field) {
    final primaryKeyAnnotations = field.metadata.where(isPrimaryKeyAnnotation);

    bool isPrimaryKey = false;
    bool autoGenerate;

    if (primaryKeyAnnotations.isNotEmpty) {
      isPrimaryKey = true;
      autoGenerate = primaryKeyAnnotations.first
          .computeConstantValue()
          .getField('autoGenerate')
          .toBoolValue();
    }

    final columnType = getColumnType(field.type);

    if (columnType == null) {
      throw InvalidGenerationSourceError(
        'Column type is not supported for ${field.type}.',
        element: field,
      );
    }

    return Column(
      field.displayName,
      columnType,
      isPrimaryKey,
      autoGenerate,
    );
  }
}
