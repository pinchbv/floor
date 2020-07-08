import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Query;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/query.dart';
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

    final query =
        QueryProcessor(_methodElement, _getQuery(), _analyzerEngine).process();

    _assertMatchingReturnType(returnType, query.resultColumnTypes);

    return QueryMethod(
      _methodElement,
      name,
      query,
      returnType,
      parameters,
    );
  }

  @nonNull
  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        ?.getField(AnnotationField.queryValue)
        ?.toStringValue();

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
      throw _processorError.doesNotReturnQueryableOrPrimitive;
    }
  }

  void _assertMatchingReturnType(
      QueryMethodReturnType dartType, List<SqlResultColumn> sqliteColumns) {
    if (sqliteColumns.isEmpty) {
      if (!dartType.isVoid || !dartType.isFuture) {
        throw _processorError.doesNotReturnVoidFuture;
      }
    } else {
      // TODO typeconverters
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
