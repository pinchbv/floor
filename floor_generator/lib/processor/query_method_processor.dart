import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Query;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';

class QueryMethodProcessor extends Processor<QueryMethod> {
  final QueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final List<Queryable> _queryables;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
  )   : assert(methodElement != null),
        assert(queryables != null),
        _methodElement = methodElement,
        _queryables = queryables,
        _processorError = QueryMethodProcessorError(methodElement);

  @nonNull
  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final rawReturnType = _methodElement.returnType;

    final query = _getQuery();
    final returnsStream = rawReturnType.isStream;

    _assertReturnsFutureOrStream(rawReturnType, returnsStream);

    final flattenedReturnType = _getFlattenedReturnType(
      rawReturnType,
      returnsStream,
    );

    final queryable = _queryables.firstWhere(
        (queryable) =>
            queryable.classElement.displayName ==
            flattenedReturnType.getDisplayString(),
        orElse: () => null);

    return QueryMethod(
      _methodElement,
      name,
      query,
      rawReturnType,
      flattenedReturnType,
      parameters,
      queryable,
    );
  }

  @nonNull
  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        .getField(AnnotationField.queryValue)
        ?.toStringValue()
        ?.replaceAll('\n', ' ')
        ?.replaceAll(RegExp(r'[ ]{2,}'), ' ')
        ?.trim();

    if (query == null || query.isEmpty) throw _processorError.noQueryDefined;

    final substitutedQuery = query.replaceAll(RegExp(r':[.\w]+'), '?');
    _assertQueryParameters(substitutedQuery, _methodElement.parameters);
    return _replaceInClauseArguments(substitutedQuery);
  }

  @nonNull
  String _replaceInClauseArguments(final String query) {
    var index = 0;
    return query.replaceAllMapped(
      RegExp(r'( in )\([?]\)', caseSensitive: false),
      (match) {
        index++;
        final matchedString = match.input.substring(match.start, match.end);
        return matchedString.replaceFirst(
          RegExp(r'(\?)'),
          '\$valueList$index',
        );
      },
    );
  }

  @nonNull
  DartType _getFlattenedReturnType(
    final DartType rawReturnType,
    final bool returnsStream,
  ) {
    final returnsList = _getReturnsList(rawReturnType, returnsStream);

    final type = returnsStream
        ? _methodElement.returnType.flatten()
        : _methodElement.library.typeSystem.flatten(rawReturnType);
    if (returnsList) {
      return type.flatten();
    }
    return type;
  }

  @nonNull
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
    final queryParameterCount = RegExp(r'\?').allMatches(query).length;

    if (queryParameterCount != parameterElements.length) {
      throw _processorError.queryArgumentsAndMethodParametersDoNotMatch;
    }
  }
}
