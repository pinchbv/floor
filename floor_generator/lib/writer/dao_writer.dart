import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/delete_method.dart';
import 'package:floor_generator/value_object/insert_method.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/writer/adapter/deletion_adapters_writer.dart';
import 'package:floor_generator/writer/adapter/insertion_adapters_writer.dart';
import 'package:floor_generator/writer/adapter/query_adapter_writer.dart';
import 'package:floor_generator/writer/adapter/update_adapters_writer.dart';
import 'package:floor_generator/writer/change_method_writer.dart';
import 'package:floor_generator/writer/delete_method_body_writer.dart';
import 'package:floor_generator/writer/insert_method_body_writer.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:floor_generator/writer/transaction_method_writer.dart';
import 'package:floor_generator/writer/update_method_body_writer.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class DaoWriter extends Writer {
  final LibraryReader library;
  final Dao dao;

  DaoWriter(this.library, this.dao);

  @override
  Class write() {
    const databaseFieldName = 'database';
    const changeListenerFieldName = 'changeListener';

    final daoName = dao.name;
    final builder = ClassBuilder()
      ..name = '_\$$daoName'
      ..extend = refer(daoName)
      ..constructors
          .add(_createConstructor(databaseFieldName, changeListenerFieldName))
      ..fields
          .addAll(_createFields(databaseFieldName, changeListenerFieldName));

    final streamEntities = dao.getStreamEntities(library);

    final queryMethods = dao.queryMethods;
    if (queryMethods.isNotEmpty) {
      QueryAdapterWriter(
        library,
        builder,
        queryMethods,
        streamEntities.isNotEmpty,
      ).write();
    }

    final insertMethods = dao.insertMethods;
    if (insertMethods.isNotEmpty) {
      InsertionAdaptersWriter(library, builder, insertMethods, streamEntities)
          .write();
    }

    final updateMethods = dao.updateMethods;
    if (updateMethods.isNotEmpty) {
      UpdateAdaptersWriter(library, builder, updateMethods, streamEntities)
          .write();
    }

    final deleteMethods = dao.deleteMethods;
    if (deleteMethods.isNotEmpty) {
      DeletionAdaptersWriter(library, builder, deleteMethods, streamEntities)
          .write();
    }

    builder
      ..methods.addAll(_generateQueryMethods(queryMethods))
      ..methods.addAll(_generateInsertMethods(insertMethods))
      ..methods.addAll(_generateUpdateMethods(updateMethods))
      ..methods.addAll(_generateDeleteMethods(deleteMethods))
      ..methods.addAll(_generateTransactionMethods(dao.transactionMethods));

    return builder.build();
  }

  Constructor _createConstructor(
    final String databaseName,
    final String changeListenerName,
  ) {
    final databaseParameter = Parameter((builder) => builder
      ..name = databaseName
      ..toThis = true);

    final changeListenerParameter = Parameter((builder) => builder
      ..name = changeListenerName
      ..toThis = true);

    return Constructor((builder) => builder
      ..requiredParameters
          .addAll([databaseParameter, changeListenerParameter]));
  }

  List<Field> _createFields(
    final String databaseName,
    final String changeListenerName,
  ) {
    final databaseField = Field((builder) => builder
      ..name = databaseName
      ..type = refer('sqflite.DatabaseExecutor')
      ..modifier = FieldModifier.final$);

    final changeListenerField = Field((builder) => builder
      ..name = changeListenerName
      ..type = refer('StreamController<String>')
      ..modifier = FieldModifier.final$);

    return [databaseField, changeListenerField];
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
}
