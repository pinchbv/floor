import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
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
    if (_queryMethod.returnsVoid) {
      return "await _queryAdapter.queryNoReturn('${_queryMethod.query}');";
    }

    final mapper = '_${_queryMethod.entity.name}Mapper';

    if (_queryMethod.returnsStream) {
      return _generateStreamQuery(mapper);
    } else {
      return _generateQuery(mapper);
    }
  }

  String _generateQuery(final String mapper) {
    if (_queryMethod.returnsList) {
      return "return _queryAdapter.queryList('${_queryMethod.query}', $mapper);";
    } else {
      return "return _queryAdapter.query('${_queryMethod.query}', $mapper);";
    }
  }

  String _generateStreamQuery(final String mapper) {
    final entityName = _queryMethod.entity.name;

    if (_queryMethod.returnsList) {
      return "return _queryAdapter.queryListStream('${_queryMethod.query}', '$entityName', $mapper);";
    } else {
      return "return _queryAdapter.queryStream('${_queryMethod.query}', '$entityName', $mapper);";
    }
  }
}
