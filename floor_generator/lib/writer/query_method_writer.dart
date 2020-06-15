import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/string_utils.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodWriter implements Writer {
  final QueryMethod _queryMethod;

  QueryMethodWriter(final QueryMethod queryMethod)
      : assert(queryMethod != null),
        _queryMethod = queryMethod;

  @override
  Method write() {
    return _generateQueryMethod();
  }

  Method _generateQueryMethod() {
    final builder = MethodBuilder()
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(_queryMethod.returnType.raw.getDisplayString())
      ..name = _queryMethod.name
      ..requiredParameters.addAll(_generateMethodParameters())
      ..body = Code(_generateMethodBody());

    if (_queryMethod.returnType.isFuture) {
      builder..modifier = MethodModifier.async;
    }

    return builder.build();
  }

  List<Parameter> _generateMethodParameters() {
    return _queryMethod.parameters.map((parameter) {
      if (!parameter.type.isSupported) {
        throw InvalidGenerationSourceError(
          'The type of this parameter is not supported.',
          element: parameter,
        );
      }

      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.getDisplayString()));
    }).toList();
  }

  String _generateMethodBody() {
    final _methodBody = StringBuffer();

    // generate the variable definitions which will store the sqlite argument
    // lists, e.g. '?5,?6,?7,?8'. These have to be generated for each call to
    // the querymethod to accomodate for different list sizes. This is
    // necessary to guarantee that each single value is inserted at the right
    // place and only via sqlites escape-mechanism.
    // If no List parameters are present, Nothing will be written.
    _methodBody.write(_generateListConvertersForQuery());

    //generate the common inputs for all queries
    final arguments = _generateArguments();
    final query = _generateQueryString();

    if (_queryMethod.returnType.isVoid) {
      _methodBody.write(_generateNoReturnQuery(query, arguments));
    } else {
      _methodBody.write(_generateQuery(query, arguments));
    }

    return _methodBody.toString();
  }

  @nonNull
  List<String> _generateParameters() {
    //TODO Typeconverters
    return [
      ..._queryMethod.parameters
          .where((param) => !param.type.isDartCoreList)
          .map((parameter) {
        if (parameter.type.isDartCoreBool) {
          return '${parameter.displayName} == null ? null : (${parameter.displayName} ? 1 : 0)';
        } else {
          return parameter.displayName;
        }
      }),
      ..._queryMethod.parameters
          .where((param) => param.type.isDartCoreList)
          .map((parameter) => '...${parameter.displayName}')
    ];
  }

  @nullable
  String _generateArguments() {
    final parameters = _generateParameters();
    return parameters.isNotEmpty ? '<dynamic>[${parameters.join(', ')}]' : null;
  }

  @nonNull
  String _generateNoReturnQuery(
      @nonNull final String query, @nullable final String arguments) {
    final affected =
        _generateSetStringOrNull(_queryMethod.sqliteContext.affectedEntities);

    final parameters = StringBuffer()..write(query);
    if (arguments != null) parameters.write(', arguments: $arguments');
    if (affected != null) parameters.write(', changedEntities: $affected');

    return 'await _queryAdapter.queryNoReturn($parameters);';
  }

  @nonNull
  String _generateQuery(
    @nonNull final String query,
    @nullable final String arguments,
  ) {
    final mapper = _generateMapper();
    final deps = _queryMethod.returnType.isStream
        ? _generateSetStringOrNull(
            _queryMethod.sqliteContext.dependencies.map((e) => e.name))
        : null;

    final parameters = StringBuffer()..write(query)..write(', mapper: $mapper');
    if (arguments != null) parameters.write(', arguments: $arguments');
    if (deps != null) parameters.write(', dependencies: $deps');

    final list = _queryMethod.returnType.isList ? 'List' : '';
    final stream = _queryMethod.returnType.isStream ? 'Stream' : '';

    return 'return _queryAdapter.query$list$stream($parameters);';
  }

  @nonNull
  String _generateListConvertersForQuery() {
    final start = _queryMethod.parameters
            .where((param) => !param.type.isDartCoreList)
            .length +
        1;
    final code = StringBuffer();
    String lastParam;
    for (final listParam in _queryMethod.parameters
        .where((param) => param.type.isDartCoreList)) {
      if (lastParam == null) {
        code.write('int _start=$start;');
      } else {
        code.write('_start+=$lastParam.length;');
      }
      code.write('final _sqliteVariablesFor${listParam.displayName}=');
      code.write('Iterable<String>.generate(');
      code.write("${listParam.displayName}.length,(i)=>'?\${i+_start}'");
      code.write(").join(',');");

      lastParam = listParam.displayName;
    }
    return code.toString();
  }

  /// Generates the Query string while accounting for the dynamically-inserted
  /// list parameters (created as `_sqliteVariablesForX`).
  @nonNull
  String _generateQueryString() {
    final code = StringBuffer();
    int start = 0;
    final originalQuery = _queryMethod.sqliteContext.processedQuery;
    for (final posAndName
        in _queryMethod.sqliteContext.listInsertionPositions.entries) {
      code.write('r""" ${originalQuery.substring(start, posAndName.key)} """');

      code.write('+ _sqliteVariablesFor${posAndName.value} +');
      start = posAndName.key + varlistPlaceholder.length;
    }
    code.write('r""" ${originalQuery.substring(start)} """');

    return code.toString();
  }

  @nullable
  String _generateSetStringOrNull(Iterable<String> input) {
    final iter = input.map((e) => "'${e.replaceAll("'", "\\'")}'");
    return iter.isNotEmpty ? '{ ${iter.join(', ')} }' : null;
  }

  @nonNull
  String _generateMapper() {
    //TODO queryable can be null; mapper has to be generated as column name (Map<String, dynamic> row) => row.values.first as <type>
    return '_${_queryMethod.returnType.queryable.name.decapitalize()}Mapper';
  }
}
