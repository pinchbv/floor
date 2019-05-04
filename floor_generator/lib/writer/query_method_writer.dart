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
      ..returns = refer(_queryMethod.rawReturnType.displayName)
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
      if (!isSupportedType(parameter.type)) {
        InvalidGenerationSourceError(
          'The type of this parameter is not supported.',
          element: parameter,
        );
      }

      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.displayName));
    }).toList();
  }

  String _generateMethodBody() {
    final parameters =
        _queryMethod.parameters.map((parameter) => parameter.displayName);
    final arguments =
        parameters.isNotEmpty ? '<dynamic>[${parameters.join(', ')}]' : null;

    if (_queryMethod.returnsVoid) {
      return _generateNoReturnQuery(arguments);
    }

    final mapper = '_${decapitalize(_queryMethod.entity.name)}Mapper';

    if (_queryMethod.returnsStream) {
      return _generateStreamQuery(arguments, mapper);
    } else {
      return _generateQuery(arguments, mapper);
    }
  }

  @nonNull
  String _generateNoReturnQuery(String arguments) {
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
    final entityName = _queryMethod.entity.name;

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
