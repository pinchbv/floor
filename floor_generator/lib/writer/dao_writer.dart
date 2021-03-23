// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/writer/deletion_method_writer.dart';
import 'package:floor_generator/writer/insertion_method_writer.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:floor_generator/writer/transaction_method_writer.dart';
import 'package:floor_generator/writer/update_method_writer.dart';
import 'package:floor_generator/writer/writer.dart';

/// Creates the implementation of a DAO.
class DaoWriter extends Writer {
  final Dao dao;
  final Set<Entity> streamEntities;
  final bool dbHasViewStreams;
  final String databaseNameType;

  DaoWriter(this.dao, this.streamEntities, this.dbHasViewStreams, this.databaseNameType);

  @override
  Class write() {
    const databaseFieldName = 'floorDatabase';
    const changeListenerFieldName = 'changeListener';

    final daoName = dao.name;
    final classBuilder = ClassBuilder()
      ..name = '_\$$daoName'
      ..extend = refer(daoName)
      ..fields
          .addAll(_createFields(databaseFieldName, changeListenerFieldName));

    final databaseParameter = Parameter((builder) => builder
      ..name = databaseFieldName
      ..toThis = true);

    final changeListenerParameter = Parameter((builder) => builder
      ..name = changeListenerFieldName
      ..toThis = true);

    final constructorBuilder = ConstructorBuilder()
      ..requiredParameters.addAll([databaseParameter, changeListenerParameter]);

    final queryMethods = dao.queryMethods;
    if (queryMethods.isNotEmpty) {
      classBuilder
        ..fields.add(Field((builder) => builder
          ..modifier = FieldModifier.final$
          ..name = '_queryAdapter'
          ..type = refer('QueryAdapter')));

      final queriesRequireChangeListener =
          dao.streamEntities.isNotEmpty || dao.streamViews.isNotEmpty;

      constructorBuilder
        ..initializers.add(Code(
            "_queryAdapter = QueryAdapter(floorDatabase.database${queriesRequireChangeListener ? ', changeListener: changeListener' : ''})"));
    }

    final insertionMethods = dao.insertionMethods;
    if (insertionMethods.isNotEmpty) {
      final entities = insertionMethods.map((method) => method.entity).toSet();

      for (final entity in entities) {
        final entityClassName = entity.classElement.displayName;
        final fieldName = '_${entityClassName.decapitalize()}InsertionAdapter';
        final type = refer('InsertionAdapter<$entityClassName>');

        final field = Field((builder) => builder
          ..name = fieldName
          ..type = type
          ..modifier = FieldModifier.final$);

        classBuilder.fields.add(field);

        final valueMapper =
            '(${entity.classElement.displayName} item) => ${entity.valueMappingForInsert}';

        final requiresChangeListener =
            dbHasViewStreams || streamEntities.contains(entity);

        final insertedBody = StringBuffer();
        if (entity.primaryKey.fields.length == 1) {
          final primaryKeyField = entity.primaryKey.fields[0];
          if (entity.primaryKey.autoGenerateId && primaryKeyField.fieldElement.type.isDartCoreInt) {
            insertedBody.writeln('entity.${primaryKeyField.name} = id;');
          }
        }
        if (entity.saveSub.isNotEmpty) {
          insertedBody.writeln(entity.saveSub);
        }
        final insertedCode = insertedBody.isEmpty ? '' : ', inserted: (id, entity) { $insertedBody }';
        constructorBuilder
          ..initializers.add(Code(
              "$fieldName = InsertionAdapter(floorDatabase.database, '${entity.name}', $valueMapper$insertedCode${requiresChangeListener ? ', changeListener: changeListener' : ''})"));
      }
    }

    final updateMethods = dao.updateMethods;
    if (updateMethods.isNotEmpty) {
      final entities = updateMethods.map((method) => method.entity).toSet();

      for (final entity in entities) {
        final entityClassName = entity.classElement.displayName;
        final fieldName = '_${entityClassName.decapitalize()}UpdateAdapter';
        final type = refer('UpdateAdapter<$entityClassName>');

        final field = Field((builder) => builder
          ..name = fieldName
          ..type = type
          ..modifier = FieldModifier.final$);

        classBuilder.fields.add(field);

        final valueMapper =
            '(${entity.classElement.displayName} item) => ${entity.valueMappingForUpdate}';

        final requiresChangeListener =
            dbHasViewStreams || streamEntities.contains(entity);

        final String updatedCode;
        if (entity.saveSub.isNotEmpty) {
          updatedCode = ', updated: (entity) { ${entity.saveSub} }';
        } else{
          updatedCode = '';
        }

        constructorBuilder
          ..initializers.add(Code(
              "$fieldName = UpdateAdapter(floorDatabase.database, '${entity.name}', ${entity.primaryKey.fields.map((field) => '\'${field.columnName}\'').toList()}, $valueMapper$updatedCode${requiresChangeListener ? ', changeListener: changeListener' : ''})"));
      }
    }

    final deleteMethods = dao.deletionMethods;
    if (deleteMethods.isNotEmpty) {
      final entities = deleteMethods.map((method) => method.entity).toSet();

      for (final entity in entities) {
        final entityClassName = entity.classElement.displayName;
        final fieldName = '_${entityClassName.decapitalize()}DeletionAdapter';
        final type = refer('DeletionAdapter<$entityClassName>');

        final field = Field((builder) => builder
          ..name = fieldName
          ..type = type
          ..modifier = FieldModifier.final$);

        classBuilder.fields.add(field);

        final valueMapper =
            '(${entity.classElement.displayName} item) => ${entity.valueMappingForDelete}';

        final requiresChangeListener =
            dbHasViewStreams || streamEntities.contains(entity);

        final String deletedCode;
        if (entity.saveSub.isNotEmpty) {
          deletedCode = '';
        } else{
          deletedCode = '';
        }

        constructorBuilder
          ..initializers.add(Code(
              "$fieldName = DeletionAdapter(floorDatabase.database, '${entity.name}', ${entity.primaryKey.fields.map((field) => '\'${field.columnName}\'').toList()}, $valueMapper$deletedCode${requiresChangeListener ? ', changeListener: changeListener' : ''})"));
      }
    }

    classBuilder
      ..constructors.add(constructorBuilder.build())
      ..methods.addAll(_generateQueryMethods(queryMethods))
      ..methods.addAll(_generateInsertionMethods(insertionMethods))
      ..methods.addAll(_generateUpdateMethods(updateMethods))
      ..methods.addAll(_generateDeletionMethods(deleteMethods))
      ..methods.addAll(_generateTransactionMethods(dao.transactionMethods));

    return classBuilder.build();
  }

  List<Field> _createFields(
    final String databaseName,
    final String changeListenerName,
  ) {
    final databaseField = Field((builder) => builder
      ..name = databaseName
      ..type = refer('_\$${databaseNameType}')
      ..modifier = FieldModifier.final$);

    final changeListenerField = Field((builder) => builder
      ..name = changeListenerName
      ..type = refer('StreamController<String>')
      ..modifier = FieldModifier.final$);

    return [databaseField, changeListenerField];
  }

  List<Method> _generateInsertionMethods(
    final List<InsertionMethod> insertionMethods,
  ) {
    return insertionMethods
        .map((method) => InsertionMethodWriter(method).write())
        .toList();
  }

  List<Method> _generateUpdateMethods(
    final List<UpdateMethod> updateMethods,
  ) {
    return updateMethods
        .map((method) => UpdateMethodWriter(method).write())
        .toList();
  }

  List<Method> _generateDeletionMethods(
    final List<DeletionMethod> deletionMethods,
  ) {
    return deletionMethods
        .map((method) => DeletionMethodWriter(method).write())
        .toList();
  }

  List<Method> _generateQueryMethods(final List<QueryMethod> queryMethods) {
    return queryMethods
        .map((method) => QueryMethodWriter(method).write())
        .toList();
  }

  List<Method> _generateTransactionMethods(
    final List<TransactionMethod> transactionMethods,
  ) {
    return transactionMethods
        .map((method) => TransactionMethodWriter(method).write())
        .toList();
  }
}
