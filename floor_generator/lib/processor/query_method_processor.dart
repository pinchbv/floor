import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Query;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/view.dart';

class QueryMethodProcessor extends Processor<QueryMethod> {
  final QueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final List<Entity> _entities;
  final List<View> _views;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities,
    final List<View> views,
  )   : assert(methodElement != null),
        assert(entities != null),
        assert(views != null),
        _methodElement = methodElement,
        _entities = entities,
        _views = views,
        _processorError = QueryMethodProcessorError(methodElement);

  @nonNull
  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final rawReturnType = _methodElement.returnType;

    final query = _getQuery();
    final isRaw = _getIsRaw();
    final returnsStream = rawReturnType.isStream;

    _assertReturnsFutureOrStream(rawReturnType, returnsStream);

    final flattenedReturnType = _getFlattenedReturnType(
      rawReturnType,
      returnsStream,
    );

    final queryable = _entities.firstWhere(
            (entity) =>
                entity.classElement.displayName ==
                flattenedReturnType.getDisplayString(),
            orElse: () => null) ??
        _views.firstWhere(
            (view) =>
                view.classElement.displayName ==
                flattenedReturnType.getDisplayString(),
            orElse: () => null); // doesn't return entity nor view
    _assertViewQueryDoesNotReturnStream(queryable, returnsStream);

    return QueryMethod(
      _methodElement,
      name,
      query,
      rawReturnType,
      flattenedReturnType,
      parameters,
      queryable,
      isRaw: isRaw
    );
  }

  @nonNull
  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        .getField(AnnotationField.QUERY_VALUE)
        ?.toStringValue()
        ?.replaceAll('\n', ' ')
        ?.replaceAll(RegExp(r'[ ]{2,}'), ' ')
        ?.trim();

    if (query == null || query.isEmpty) throw _processorError.NO_QUERY_DEFINED;

    final substitutedQuery = query.replaceAll(RegExp(r':[^\s)]+'), '?');
    _assertQueryParameters(substitutedQuery, _methodElement.parameters);
    return _replaceInClauseArguments(substitutedQuery);
  }

  @nonNull
  bool _getIsRaw() {
    final isRaw = _methodElement
      .getAnnotation(annotations.Query)
      .getField(AnnotationField.QUERY_IS_RAW)
      ?.toBoolValue();

      return isRaw ?? false;
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
      throw _processorError.DOES_NOT_RETURN_FUTURE_NOR_STREAM;
    }
  }

  void _assertViewQueryDoesNotReturnStream(
    final Queryable queryable,
    final bool returnsStream,
  ) {
    if (queryable != null && queryable is View && returnsStream) {
      throw _processorError.VIEW_NOT_STREAMABLE;
    }
  }

  void _assertQueryParameters(
    final String query,
    final List<ParameterElement> parameterElements,
  ) {
    final queryParameterCount = RegExp(r'\?').allMatches(query).length;

    if (queryParameterCount != parameterElements.length) {
      throw _processorError.QUERY_ARGUMENTS_AND_METHOD_PARAMETERS_DO_NOT_MATCH;
    }
  }
}
