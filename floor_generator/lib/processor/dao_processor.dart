import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/deletion_method_processor.dart';
import 'package:floor_generator/processor/insertion_method_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_method_processor.dart';
import 'package:floor_generator/processor/transaction_method_processor.dart';
import 'package:floor_generator/processor/update_method_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/value_object/update_method.dart';

class DaoProcessor extends Processor<Dao> {
  final ClassElement _classElement;
  final String _daoGetterName;
  final String _databaseName;
  final List<Entity> _entities;

  DaoProcessor(
    final ClassElement classElement,
    final String daoGetterName,
    final String databaseName,
    final List<Entity> entities,
  )   : assert(classElement != null),
        assert(daoGetterName != null),
        assert(databaseName != null),
        assert(entities != null),
        _classElement = classElement,
        _daoGetterName = daoGetterName,
        _databaseName = databaseName,
        _entities = entities;

  @override
  Dao process() {
    final name = _classElement.displayName;
    final methods = _classElement.methods;

    final queryMethods = _getQueryMethods(methods);
    final insertionMethods = _getInsertionMethods(methods);
    final updateMethods = _getUpdateMethods(methods);
    final deletionMethods = _getDeletionMethods(methods);
    final transactionMethods = _getTransactionMethods(methods);

    final streamEntities = _getStreamEntities(queryMethods);

    return Dao(
      _classElement,
      name,
      queryMethods,
      insertionMethods,
      updateMethods,
      deletionMethods,
      transactionMethods,
      streamEntities,
    );
  }

  List<QueryMethod> _getQueryMethods(List<MethodElement> methods) {
    return methods
        .where((method) => method.metadata.any(isQueryAnnotation))
        .map((method) => QueryMethodProcessor(method, _entities).process())
        .toList();
  }

  List<InsertionMethod> _getInsertionMethods(
    List<MethodElement> methodElements,
  ) {
    return methodElements
        .where((method) => method.metadata.any(isInsertAnnotation))
        .map((method) => InsertionMethodProcessor(method, _entities).process())
        .toList();
  }

  List<UpdateMethod> _getUpdateMethods(List<MethodElement> methods) {
    return methods
        .where((method) => method.metadata.any(isUpdateAnnotation))
        .map((method) => UpdateMethodProcessor(method, _entities).process())
        .toList();
  }

  List<DeletionMethod> _getDeletionMethods(List<MethodElement> methods) {
    return methods
        .where((method) => method.metadata.any(isDeleteAnnotation))
        .map((method) => DeletionMethodProcessor(method, _entities).process())
        .toList();
  }

  List<TransactionMethod> _getTransactionMethods(List<MethodElement> methods) {
    return methods
        .where((method) => method.metadata.any(isTransactionAnnotation))
        .map((method) =>
            TransactionMethodProcessor(method, _daoGetterName, _databaseName)
                .process())
        .toList();
  }

  List<Entity> _getStreamEntities(final List<QueryMethod> queryMethods) {
    return queryMethods
        .where((method) => method.returnsStream)
        .map((method) => method.entity)
        .toList();
  }
}
