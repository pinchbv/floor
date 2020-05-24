import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
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
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/value_object/view.dart';

class DaoProcessor extends Processor<Dao> {
  final ClassElement _classElement;
  final String _daoGetterName;
  final String _databaseName;
  final List<Entity> _entities;
  final List<View> _views;
  final List<TypeConverter> _typeConverters;

  DaoProcessor(
    final ClassElement classElement,
    final String daoGetterName,
    final String databaseName,
    final List<Entity> entities,
    final List<View> views,
    final List<TypeConverter> typeConverters,
  )   : assert(classElement != null),
        assert(daoGetterName != null),
        assert(databaseName != null),
        assert(entities != null),
        assert(views != null),
        assert(typeConverters != null),
        _classElement = classElement,
        _daoGetterName = daoGetterName,
        _databaseName = databaseName,
        _entities = entities,
        _views = views,
        _typeConverters = typeConverters;

  @override
  Dao process() {
    final name = _classElement.displayName;
    final methods = [
      ..._classElement.methods,
      ..._classElement.allSupertypes.expand((type) => type.methods)
    ];

    final typeConverters = _typeConverters +
        _classElement.getTypeConverters(TypeConverterScope.dao);

    final queryMethods = _getQueryMethods(methods, typeConverters);
    final insertionMethods = _getInsertionMethods(methods);
    final updateMethods = _getUpdateMethods(methods);
    final deletionMethods = _getDeletionMethods(methods);
    final transactionMethods = _getTransactionMethods(methods);

    final streamQueryables = queryMethods
        .where((method) => method.returnsStream)
        .map((method) => method.queryable);
    final streamEntities = streamQueryables.whereType<Entity>().toSet();
    final streamViews = streamQueryables.whereType<View>().toSet();

    return Dao(
      _classElement,
      name,
      queryMethods,
      insertionMethods,
      updateMethods,
      deletionMethods,
      transactionMethods,
      streamEntities,
      streamViews,
      typeConverters
          .toSet(), // TODO #165 make all type converter collections sets
    );
  }

  List<QueryMethod> _getQueryMethods(
    final List<MethodElement> methods,
    final List<TypeConverter> typeConverters,
  ) {
    return methods
        .where((method) => method.hasAnnotation(annotations.Query))
        .map((method) => QueryMethodProcessor(
              method,
              [..._entities, ..._views],
              typeConverters,
            ).process())
        .toList();
  }

  List<InsertionMethod> _getInsertionMethods(
    final List<MethodElement> methodElements,
  ) {
    return methodElements
        .where(
            (methodElement) => methodElement.hasAnnotation(annotations.Insert))
        .map((method) => InsertionMethodProcessor(method, _entities).process())
        .toList();
  }

  List<UpdateMethod> _getUpdateMethods(
    final List<MethodElement> methodElements,
  ) {
    return methodElements
        .where(
            (methodElement) => methodElement.hasAnnotation(annotations.Update))
        .map((methodElement) =>
            UpdateMethodProcessor(methodElement, _entities).process())
        .toList();
  }

  List<DeletionMethod> _getDeletionMethods(
    final List<MethodElement> methodElements,
  ) {
    return methodElements
        .where((methodElement) =>
            methodElement.hasAnnotation(annotations.delete.runtimeType))
        .map((methodElement) =>
            DeletionMethodProcessor(methodElement, _entities).process())
        .toList();
  }

  List<TransactionMethod> _getTransactionMethods(
    final List<MethodElement> methodElements,
  ) {
    return methodElements
        .where((methodElement) =>
            methodElement.hasAnnotation(annotations.transaction.runtimeType))
        .map((methodElement) => TransactionMethodProcessor(
              methodElement,
              _daoGetterName,
              _databaseName,
            ).process())
        .toList();
  }
}
