import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query.dart';

class QueryProcessor extends Processor<Query> {
  final QueryProcessorError _processorError;

  final String _query;

  final List<ParameterElement> _parameters;

  QueryProcessor(MethodElement methodElement, this._query)
      : _parameters = methodElement.parameters,
        _processorError = QueryProcessorError(methodElement);

  @override
  Query process() {
    _assertNoNullableParameters();

    final indices = <String, int>{};
    final fixedParameters = <String>{};
    //map parameters to index (1-based) or 0 (if its a list)
    int currentIndex = 1;
    for (final parameter in _parameters) {
      if (parameter.type.isDartCoreList) {
        indices[':${parameter.name}'] = 0;
      } else {
        fixedParameters.add(parameter.name);
        indices[':${parameter.name}'] = currentIndex++;
      }
    }

    //get List of query variables
    final variables = findVariables(_query);
    _assertAllParametersAreUsed(variables);

    final newQuery = StringBuffer();
    final listParameters = <ListParameter>[];
    // iterate over all found variables, replace them with their assigned
    // numbered variable (?1,?2,...) or a placeholder if the variable is a list.
    // the list variables have to be handled in the writer, so write down their
    // positions and names.
    int currentLast = 0;
    for (final varToken in variables) {
      newQuery.write(_query
          .substring(currentLast, varToken.startPosition)
          .replaceAll('\n', ' '));
      final varIndexInMethod = indices[varToken.name];
      if (varIndexInMethod == null) {
        throw _processorError.unknownQueryVariable(varToken.name);
      } else if (varIndexInMethod > 0) {
        //normal variable/parameter
        if (varToken.isListVar)
          throw _processorError
              .queryMethodParameterIsNormalButVariableIsList(varToken.name);
        newQuery.write('?');
        newQuery.write(varIndexInMethod);
      } else {
        //list variable/parameter
        if (!varToken.isListVar)
          throw _processorError
              .queryMethodParameterIsListButVariableIsNot(varToken.name);
        listParameters
            .add(ListParameter(newQuery.length, varToken.name.substring(1)));
        newQuery.write(varlistPlaceholder);
      }
      currentLast = varToken.endPosition;
    }
    newQuery.write(_query.substring(currentLast).replaceAll('\n', ' '));

    return Query(
      newQuery.toString(),
      listParameters,
    );
  }

  void _assertNoNullableParameters() {
    for (final parameter in _parameters) {
      if (parameter.type.isNullable) {
        throw _processorError.queryMethodParameterIsNullable(parameter);
      }
    }
  }

  void _assertAllParametersAreUsed(List<VariableToken> variables) {
    final queryVariables = variables.map((e) => e.name.substring(1)).toSet();
    for (final param in _parameters) {
      if (!queryVariables.contains(param.displayName)) {
        throw _processorError.unusedQueryMethodParameter(param);
      }
    }
  }
}

/// Treats the incoming String as an Sqlite query and tries to find all used
/// sqlite variables. Also try do identify List variables by looking at their
/// context.
List<VariableToken> findVariables(final String query) {
  final output = <VariableToken>[];
  for (final match
      in RegExp(r':[\w]+| [iI][nN]\s*\((:[\w]+)\)').allMatches(query)) {
    final content = match.group(0)!;
    final expectsList = content.toLowerCase().startsWith(' in');
    if (expectsList) {
      final varname = match.group(1)!;
      output.add(
          VariableToken(varname, query.indexOf(varname, match.start), true));
    } else {
      output.add(VariableToken(content, match.start, false));
    }
  }
  return output;
}

/// Represents a variable within an sqlite query.
class VariableToken {
  /// the variable name including `:` (e.g. `:foo`)
  final String name;

  /// the offset within the query, where the variable name starts. Useful for
  /// splitting the query here.
  final int startPosition;

  /// the offset within the query, where the variable name ends. Useful for
  /// splitting the query here.
  int get endPosition => startPosition + name.length;

  /// denotes if the variable was determined to contain a list
  final bool isListVar;

  VariableToken(this.name, this.startPosition, this.isListVar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableToken &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          startPosition == other.startPosition &&
          isListVar == other.isListVar;

  @override
  int get hashCode =>
      name.hashCode ^ startPosition.hashCode ^ isListVar.hashCode;
}
