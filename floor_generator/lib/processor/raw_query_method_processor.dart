import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/misc/extension/set_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/raw_query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';

class RawQueryMethodProcessor extends Processor<QueryMethod> {
  final RawQueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final List<Queryable> _queryables;
  final Set<TypeConverter> _typeConverters;

  RawQueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
    final Set<TypeConverter> typeConverters,
  )   : _methodElement = methodElement,
        _queryables = queryables,
        _typeConverters = typeConverters,
        _processorError = RawQueryMethodProcessorError(methodElement);

  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    _assertRawQueryParameters(parameters);
    final rawReturnType = _methodElement.returnType;
    final returnsStream = rawReturnType.isStream;
    _assertReturnsFutureOrStream(rawReturnType, returnsStream);
    final returnsList = _getReturnsList(rawReturnType, returnsStream);

    final flattenedReturnType = _getFlattenedReturnType(
      rawReturnType,
      returnsStream,
      returnsList,
    );

    _assertReturnsNullableSingle(
      returnsStream,
      returnsList,
      flattenedReturnType,
    );

    final queryable = _queryables.firstWhereOrNull((queryable) =>
        queryable.classElement.displayName ==
        flattenedReturnType.getDisplayString(withNullability: false));

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
      null,
      rawReturnType,
      flattenedReturnType,
      parameters,
      queryable,
      allTypeConverters,
    );
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

  bool _getReturnsList(final DartType returnType, final bool returnsStream) {
    final type = returnsStream
        ? returnType.flatten()
        : _methodElement.library.typeSystem.flatten(returnType);

    return type.isDartCoreList;
  }

  void _assertReturnsFutureOrStream(
    final DartType rawReturnType,
    final bool returnsStream,
  ) {
    if (!rawReturnType.isDartAsyncFuture && !returnsStream) {
      throw _processorError.doesNotReturnFutureNorStream;
    }
  }

  void _assertRawQueryParameters(
    final List<ParameterElement> parameterElements,
  ) {
    final parametersLength = parameterElements.length;
    if (parametersLength > 1 || parametersLength == 0) {
      throw _processorError.queryArgumentsShouldBeSingle;
    }

    final parameter = parameterElements[0];
    final type = parameter.type;
    if (type.isNullable) {
      throw _processorError.queryMethodParameterIsNullable(parameter);
    }
    if (!type.isDartCoreString && !type.isSQLiteQuery) {
      throw _processorError.queryArgumentsShouldBeSingle;
    }
  }

  void _assertReturnsNullableSingle(
    final bool returnsStream,
    final bool returnsList,
    final DartType flattenedReturnType,
  ) {
    if (!returnsList &&
        !flattenedReturnType.isVoid &&
        !flattenedReturnType.isNullable) {
      if (returnsStream) {
        throw _processorError.doesNotReturnNullableStream;
      } else {
        throw _processorError.doesNotReturnNullableFuture;
      }
    }
  }
}
