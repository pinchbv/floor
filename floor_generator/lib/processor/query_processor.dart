import 'dart:collection';

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

    //get List of query variables
    final variables = findVariables(_query);
    _assertAllParametersAreUsed(variables);

    /// linkedHash ensures order
    final LinkedHashMap<String, Set<ParamType>> useTos = LinkedHashMap();
    final paramTypeMap = <String, ParamType>{};
    for (final parameter in _parameters) {
      final typeSet = variables.where((va) => va.prop == parameter.name)
          .map((e) => e.type).toSet();
      useTos[parameter.name] = typeSet;
      paramTypeMap[parameter.name] = parameter.type.isDartCoreList?ParamType.list: ParamType.normal;
    }

    final normalArgs = useTos.entries
        .where((element) => element.value.contains(ParamType.normal))
        .map((e) => e.key).toList();

    final newQuery = StringBuffer();
    final queryParameters = <QueryParameter>[];
    // iterate over all found variables, replace them with their assigned
    // numbered variable (?1,?2,...) or a placeholder if the variable is a list.
    // the list variables have to be handled in the writer, so write down their
    // positions and names.
    int currentLast = 0;

    for (final varToken in variables) {
      final paramType = paramTypeMap[varToken.prop];
      if (paramType == null) {
        throw _processorError.unknownQueryVariable(varToken.name);
      }
      if(paramType == ParamType.list && varToken.type != ParamType.list){
        throw _processorError.queryMethodParameterIsListButVariableIsNot(varToken.name);
      }
      if(paramType != ParamType.list && varToken.type == ParamType.list){
        throw _processorError.queryMethodParameterIsNormalButVariableIsList(varToken.name);
      }
      newQuery.write(_query
          .substring(currentLast, varToken.startPosition)
          .replaceAll('\n', ' '));
      switch(varToken.type) {
        case ParamType.list:
          queryParameters.add(QueryParameter(newQuery.length, varToken.prop, ParamType.list));
          newQuery.write(varlistPlaceholder);
        case ParamType.custom:
          queryParameters.add(QueryParameter(newQuery.length, varToken.prop, ParamType.custom));
          newQuery.write(varToken.name);
        default:
        //normal variable/parameter placeholder
          queryParameters.add(QueryParameter(newQuery.length, varToken.prop, ParamType.normal));
          newQuery.write('?${normalArgs.indexOf(varToken.prop) + 1}');
      }
      currentLast = varToken.endPosition;
    }
    newQuery.write(_query.substring(currentLast).replaceAll('\n', ' '));

    return Query(
      newQuery.toString(),
      queryParameters,
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
    final queryVariables = variables.map((e) => e.prop).toSet();
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
      in RegExp(r':[\w]+| [iI][nN]\s*\((:[\w]+)\)|(\{\w+\})').allMatches(query)) {
    final content = match.group(0)!;
    final expectsList = content.toLowerCase().startsWith(' in');
    final customParam =  match.group(2);
    if(customParam != null) {
      output.add(VariableToken(content, match.start, ParamType.custom));
      continue;
    }
    if (expectsList) {
      final varname = match.group(1)!;
      output.add(
          VariableToken(varname, query.indexOf(varname, match.start), ParamType.list));
    } else {
      output.add(VariableToken(content, match.start, ParamType.normal));
    }
  }
  return output;
}

/// Represents a variable within an sqlite query.
class VariableToken {
  /// the variable name including `:` (e.g. `:foo`) or `{}` (e.g `{bar}`)
  final String name;

  /// the offset within the query, where the variable name starts. Useful for
  /// splitting the query here.
  final int startPosition;

  /// the offset within the query, where the variable name ends. Useful for
  /// splitting the query here.
  int get endPosition => startPosition + name.length;

  /// the variable name excluding `:` and `{}`
  String get prop {
    if(type == ParamType.custom) return name.substring(1, name.length - 1);
    return name.substring(1);
  }

  /// denotes if the variable was determined to contain a list
  final ParamType type;

  VariableToken(this.name, this.startPosition, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableToken &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          startPosition == other.startPosition &&
          type == other.type;

  @override
  int get hashCode =>
      name.hashCode ^ startPosition.hashCode ^ type.hashCode;
}
