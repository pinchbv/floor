import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/string_utils.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/query_method.dart';
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
      ..returns = refer(_queryMethod.rawReturnType.getDisplayString())
      ..name = _queryMethod.name
      ..requiredParameters.addAll(_generateMethodParameters())
      ..body = Code(_generateMethodBody());

    if (!_queryMethod.returnsStream || _queryMethod.returnsVoid) {
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

    final valueLists = _generateInClauseValueLists();
    if (valueLists.isNotEmpty) {
      _methodBody.write(valueLists.join(''));
    }

    final arguments = _generateArguments();
    if (_queryMethod.returnsVoid) {
      _methodBody.write(_generateNoReturnQuery(arguments));
      return _methodBody.toString();
    }

    final mapper = '_${_queryMethod.queryable.name.decapitalize()}Mapper';
    if (_queryMethod.returnsStream) {
      _methodBody.write(_generateStreamQuery(arguments, mapper));
    } else {
      _methodBody.write(_generateQuery(arguments, mapper));
    }

    return _methodBody.toString();
  }

  @nonNull
  List<String> _generateInClauseValueLists() {
    var index = 0;
    return _queryMethod.parameters
        .map((parameter) {
          if (parameter.type.isDartCoreList) {
            index++;
            return '''final valueList$index = ${parameter.displayName}.map((value) => "'\$value'").join(', ');''';
          } else {
            return null;
          }
        })
        .where((string) => string != null)
        .toList();
  }

  @nonNull
  List<String> _generateParameters() {
    return _queryMethod.parameters
        .map((parameter) {
          if (!parameter.type.isDartCoreList) {
            return parameter.displayName;
          } else {
            return null;
          }
        })
        .where((string) => string != null)
        .toList();
  }

  @nullable
  String _generateArguments() {
    final parameters = _generateParameters();
    return parameters.isNotEmpty ? '<dynamic>[${parameters.join(', ')}]' : null;
  }

  @nonNull
  String _generateNoReturnQuery(@nullable final String arguments) {
    final parameters = StringBuffer()..write("'${_queryMethod.query}'");
    if (arguments != null) parameters.write(', arguments: $arguments');
    return 'await _queryAdapter.queryNoReturn($parameters);';
  }

  @nonNull
  String _generateQuery(
    @nullable final String arguments,
    @nonNull final String mapper,
  ) {
    final parameters = StringBuffer()..write("'${_queryMethod.query}', ");
    if (arguments != null) parameters.write('arguments: $arguments, ');
    if (_queryMethod.isRaw) parameters.write('isRaw: true, ');
    parameters.write('mapper: $mapper');

    if (_queryMethod.returnsList) {
      return 'return _queryAdapter.queryList($parameters);';
    } else {
      return 'return _queryAdapter.query($parameters);';
    }
  }

  @nonNull
  String _generateStreamQuery(
    @nullable final String arguments,
    @nonNull final String mapper,
  ) {
    final entityName = _queryMethod.queryable.name;

    final parameters = StringBuffer()..write("'${_queryMethod.query}', ");
    if (arguments != null) parameters.write('arguments: $arguments, ');
    parameters..write("tableName: '$entityName', ")..write('mapper: $mapper');

    if (_queryMethod.returnsList) {
      return 'return _queryAdapter.queryListStream($parameters);';
    } else {
      return 'return _queryAdapter.queryStream($parameters);';
    }
  }
}
