import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/misc/extension/set_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';

class RawQueryMethodProcessor extends Processor<QueryMethod> {
  final QueryMethodProcessorError _processorError;

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
        _processorError = QueryMethodProcessorError(methodElement);

  @override
  QueryMethod process() {
    print('Implement RawQueryMethodProcessor logic here');
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final rawReturnType = _methodElement.returnType;

    final query = _getQuery();
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
      query,
      rawReturnType,
      flattenedReturnType,
      parameters,
      queryable,
      allTypeConverters,
    );
  }

  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.RawQuery)
        .getField(AnnotationField.queryValue)
        ?.toStringValue()
        ?.replaceAll('\n', ' ')
        .replaceAll(RegExp(r'[ ]{2,}'), ' ')
        .trim();

    if (query == null || query.isEmpty) throw _processorError.noQueryDefined;

    final substitutedQuery = query.replaceAll(RegExp(r':[.\w]+'), '?');
    _assertQueryParameters(substitutedQuery, _methodElement.parameters);
    return _replaceInClauseArguments(substitutedQuery);
  }

  String _replaceInClauseArguments(final String query) {
    var index = 0;
    return query.replaceAllMapped(
      RegExp(r'( in\s*)\([?]\)', caseSensitive: false),
          (match) {
        final matched = match.input.substring(match.start, match.end);
        final replaced =
        matched.replaceFirst(RegExp(r'(\?)'), '\$valueList$index');
        index++;
        return replaced;
      },
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

  void _assertQueryParameters(
      final String query,
      final List<ParameterElement> parameterElements,
      ) {
    for (final parameter in parameterElements) {
      if (parameter.type.isNullable) {
        throw _processorError.queryMethodParameterIsNullable(parameter);
      }
    }

    final queryParameterCount = RegExp(r'\?').allMatches(query).length;
    if (queryParameterCount != parameterElements.length) {
      throw _processorError.queryArgumentsAndMethodParametersDoNotMatch;
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
