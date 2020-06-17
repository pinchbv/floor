import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Query;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_analyzer/analyzed_query.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';
import 'package:floor_generator/value_object/queryable.dart';

class QueryMethodProcessor extends Processor<QueryMethod> {
  final QueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final List<Queryable> _queryables;
  final AnalyzerEngine _analyzerEngine;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
    final AnalyzerEngine analyzerEngine,
  )   : assert(methodElement != null),
        assert(queryables != null),
        assert(analyzerEngine != null),
        _methodElement = methodElement,
        _queryables = queryables,
        _analyzerEngine = analyzerEngine,
        _processorError = QueryMethodProcessorError(methodElement);

  @nonNull
  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final returnType = _getAndCheckReturnType();

    final sqliteContext =
        _analyzerEngine.analyzeQuery(_getQuery(), _methodElement);

    _assertMatchingReturnType(returnType, sqliteContext.outputTypes);

    return QueryMethod(
      _methodElement,
      name,
      sqliteContext,
      returnType,
      parameters,
    );
  }

  @nonNull
  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        .getField(AnnotationField.queryValue)
        ?.toStringValue()
        ?.trim();

    if (query == null || query.isEmpty) throw _processorError.noQueryDefined;

    return query;
  }

  @nonNull
  QueryMethodReturnType _getAndCheckReturnType() {
    final returnType = QueryMethodReturnType(_methodElement.returnType);

    _assertReturnsFutureOrStream(returnType);

    // find a matching queryable (view or entity) for the return type
    returnType.queryable = _queryables.firstWhere(
        (queryable) =>
            queryable.classElement.displayName ==
            returnType.flattened.getDisplayString(),
        orElse: () => null);

    _assertReturnsPrimitiveOrQueryable(returnType);

    _assertVoidReturnIsFuture(returnType);

    return returnType;
  }

  void _assertReturnsFutureOrStream(final QueryMethodReturnType type) {
    if (!type.isFuture && !type.isStream) {
      throw _processorError.doesNotReturnFutureNorStream;
    }
  }

  void _assertReturnsPrimitiveOrQueryable(final QueryMethodReturnType type) {
    if (type.queryable == null && !type.isPrimitive) {
      print('TTYYPPEE: $type, KnownQueryables: $_queryables');
      throw _processorError.doesNotReturnQueryableOrPrimitive;
    }
  }

  void _assertMatchingReturnType(
      QueryMethodReturnType dartType, List<SqlResultColumn> sqliteColumns) {
    // TODO typeconverters
    if (sqliteColumns.isEmpty) {
      if (!dartType.isVoid || !dartType.isFuture) {
        throw _processorError.doesNotReturnVoidFuture;
      }
    } else {
      //TODO check types
    }
  }

  void _assertVoidReturnIsFuture(QueryMethodReturnType returnType) {
    if (returnType.isVoid && returnType.isList) {
      throw _processorError.voidReturnCannotBeList;
    }

    if (returnType.isVoid && returnType.isStream) {
      throw _processorError.voidReturnCannotBeStream;
    }
  }
}
