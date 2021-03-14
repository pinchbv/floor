import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query.dart';

class QueryProcessor extends Processor<Query> {
  final QueryMethodProcessorError _processorError;

  final String _query;

  final List<ParameterElement> _parameters;

  QueryProcessor(MethodElement methodElement, this._query)
      : _parameters = methodElement.parameters,
        _processorError = QueryMethodProcessorError(methodElement);

  @override
  Query process() {
    final listParameters = <ListParameter>[];

    final newQuery = _processParameters(listParameters);

    //TODO
    //_assertNoNamedVarsLeft(newQuery);

    return Query(
      newQuery,
      listParameters,
    );
  }

  String _processParameters(List<ListParameter> listParametersOutput) {
    final substitutedQuery = _query
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'[ ]{2,}'), ' ')
        .replaceAll(RegExp(r':[.\w]+'), '?');
    _assertQueryParameters(substitutedQuery, _parameters);
    return _replaceInClauseArguments(substitutedQuery);
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
}
