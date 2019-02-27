import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/database.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/model/transaction_method.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:floor_generator/writer/change_method_writer.dart';
import 'package:floor_generator/writer/delete_method_body_writer.dart';
import 'package:floor_generator/writer/insert_method_body_writer.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:floor_generator/writer/transaction_method_writer.dart';
import 'package:floor_generator/writer/update_method_body_writer.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

/// Takes care of generating the database implementation.
class DatabaseWriter implements Writer {
  final LibraryReader library;

  DatabaseWriter(final this.library);

  @override
  Spec write() {
    final database = _getDatabase();

    // TODO generator runs for every file of the project, so this fails without
    if (database == null) {
      return null;
    }

    return Library((builder) => builder
      ..body.addAll([
        _generateOpenDatabaseFunction(database.name),
        _generateDatabaseImplementation(database)
      ]));
  }

  Database _getDatabase() {
    final databaseClasses = library.classes.where((clazz) =>
        clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation));

    if (databaseClasses.isEmpty) {
      // TODO generator runs for every file of the project, so this fails without
      return null;
//      throw InvalidGenerationSourceError(
//          'No database defined. Add a @Database annotation to your abstract database class.');
    } else if (databaseClasses.length > 1) {
      throw InvalidGenerationSourceError(
          'Only one database is allowed. There are too many classes annotated with @Database.');
    } else {
      return Database(databaseClasses.first);
    }
  }

  Method _generateOpenDatabaseFunction(final String databaseName) {
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

  Class _generateDatabaseImplementation(final Database database) {
    final createTableStatements =
        _generateCreateTableSqlStatements(database.getEntities(library))
            .map((statement) => 'await database.execute($statement);')
            .join('\n');

    if (createTableStatements.isEmpty) {
      throw InvalidGenerationSourceError(
          'There are no entities defined. Use the @Entity annotation on model classes to do so.');
    }

    final databaseName = database.name;

    return Class((builder) => builder
      ..name = '_\$$databaseName'
      ..extend = refer(databaseName)
      ..methods.add(_generateOpenMethod(databaseName, createTableStatements))
      ..methods.addAll(_generateQueryMethods(database.queryMethods))
      ..methods.addAll(_generateInsertMethods(database.insertMethods))
      ..methods.addAll(_generateUpdateMethods(database.updateMethods))
      ..methods.addAll(_generateDeleteMethods(database.deleteMethods))
      ..methods
          .addAll(_generateTransactionMethods(database.transactionMethods)));
  }

  Method _generateOpenMethod(
    final String databaseName,
    final String createTableStatements,
  ) {
    return Method((builder) => builder
      ..name = 'open'
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer('Future<sqflite.Database>')
      ..modifier = MethodModifier.async
      ..body = Code('''
          final path = join(await sqflite.getDatabasesPath(), '${databaseName.toLowerCase()}.db');

          return sqflite.openDatabase(
            path,
            version: 1,
            onConfigure: (database) async {
              await database.execute('PRAGMA foreign_keys = ON');
            },
            onCreate: (database, version) async {
              $createTableStatements
            },
          );
          '''));
  }

  List<Method> _generateInsertMethods(final List<InsertMethod> insertMethods) {
    return insertMethods.map((method) {
      final writer = InsertMethodBodyWriter(library, method);
      return ChangeMethodWriter(library, method, writer).write();
    }).toList();
  }

  List<Method> _generateUpdateMethods(final List<UpdateMethod> updateMethods) {
    return updateMethods.map((method) {
      final writer = UpdateMethodBodyWriter(library, method);
      return ChangeMethodWriter(library, method, writer).write();
    }).toList();
  }

  List<Method> _generateDeleteMethods(final List<DeleteMethod> deleteMethods) {
    return deleteMethods.map((method) {
      final writer = DeleteMethodBodyWriter(library, method);
      return ChangeMethodWriter(library, method, writer).write();
    }).toList();
  }

  List<Method> _generateQueryMethods(final List<QueryMethod> queryMethods) {
    return queryMethods
        .map((method) => QueryMethodWriter(library, method).write())
        .toList();
  }

  List<Method> _generateTransactionMethods(
    final List<TransactionMethod> transactionMethods,
  ) {
    return transactionMethods
        .map((method) => TransactionMethodWriter(library, method).write())
        .toList();
  }

  List<String> _generateCreateTableSqlStatements(final List<Entity> entities) {
    return entities
        .map((entity) => entity.getCreateTableStatement(library))
        .toList();
  }
}
