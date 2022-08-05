import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/misc/extension/set_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/base_query_method_processor.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';

class QueryMethodProcessor extends BaseQueryMethodProcessor {
  final QueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final Set<TypeConverter> _typeConverters;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
    final Set<TypeConverter> typeConverters,
  )   : _methodElement = methodElement,
        _typeConverters = typeConverters,
        _processorError = QueryMethodProcessorError(methodElement),
        super(methodElement, queryables);

  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        ?.getField(AnnotationField.queryValue)
        ?.toStringValue()
        ?.trim();

    if (query == null || query.isEmpty) throw _processorError.noQueryDefined;
    return query;
  }

  DartType _getFlattenedReturnType(
    final DartType rawReturnType,
    final bool returnsStream,
    final bool returnsList,
  ) {
    final type = returnsStream
        ? _methodElement.returnType.flatten()
        : _methodElement.library.typeSystem.flatten(rawReturnType);
    return returnsList ? type.flatten() : type;
  }

  @override
  void onAssertReturnsNullableSingle(bool returnsStream) {
    returnsStream
        ? throw _processorError.doesNotReturnNullableStream
        : throw _processorError.doesNotReturnNullableFuture;
  }

  @override
  void onDoesNotReturnFutureNorStream() {
    throw _processorError.doesNotReturnFutureNorStream;
  }

  @override
  QueryMethod onProcess(
    MethodElement methodElement,
    String name,
    DartType returnType,
    DartType flattenedReturnType,
    List<ParameterElement> parameters,
    Queryable? queryable,
  ) {
    final query = QueryProcessor(_methodElement, _getQuery()).process();

    final parameterTypeConverters = parameters
        .expand((parameter) =>
            parameter.getTypeConverters(TypeConverterScope.daoMethodParameter))
        .toSet();

    final allTypeConverters = _typeConverters +
        _methodElement.getTypeConverters(TypeConverterScope.daoMethod) +
        parameterTypeConverters;

    if (queryable != null) {
      final fieldTypeConverters =
          queryable.fields.mapNotNull((field) => field.typeConverter);
      allTypeConverters.addAll(fieldTypeConverters);
    }

    return QueryMethod(
      _methodElement,
      name,
      query,
      returnType,
      flattenedReturnType,
      parameters,
      queryable,
      allTypeConverters,
    );
  }
}
