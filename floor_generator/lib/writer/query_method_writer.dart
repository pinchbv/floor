import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class   QueryMethodWriter implements Writer {
  final LibraryReader library;
  final QueryMethod queryMethod;

  const QueryMethodWriter(this.library, this.queryMethod);

  @override
  Method write() {
    return _generateQueryMethod(queryMethod);
  }

  Method _generateQueryMethod(QueryMethod queryMethod) {
    _assertReturnsFuture(queryMethod);
    _assertReturnsEntity(queryMethod);

    final parameters = _generateMethodParameters(queryMethod.parameters);
    final mapping = _generateMapping(queryMethod);

    // TODO extract toBool
    return Method((builder) =>
    builder
      ..annotations.add(AnnotationExpression('override'))
      ..returns = refer(queryMethod.rawReturnType.displayName)
      ..name = queryMethod.name
      ..requiredParameters.addAll(parameters)
      ..modifier = MethodModifier.async
      ..body = Code('''
      bool toBool(int value) {
        if (value == 0) {
          return false;
        } else {
          return true;
        }
      }
      
      final rows = await this.database.rawQuery('${queryMethod.query}');
      if (rows.isEmpty) {
        return null;
      }
      $mapping
      '''));
  }

  List<Parameter> _generateMethodParameters(List<ParameterElement> parameters) {
    return parameters.map((parameter) {
      if (!isSupportedType(parameter.type)) {
        InvalidGenerationSourceError(
          'The type of this parameter is not supported.',
          element: parameter,
        );
      }

      return Parameter((builder) =>
      builder
        ..name = parameter.name
        ..type = refer(parameter.type.displayName));
    }).toList();
  }

  String _generateMapping(QueryMethod queryMethod) {
    final constructorCall =
    _generateConstructorCall(queryMethod.flattenedReturnType);

    if (queryMethod.returnsList) {
      return 'return rows.map((row) => $constructorCall).toList();';
    } else {
      return '''
      final row = rows.first;
      return $constructorCall;
      ''';
    }
  }

  String _generateConstructorCall(DartType type) {
    final parameterValues = (type.element as ClassElement)
        .constructors
        .first
        .parameters
        .map((parameter) {
      final parameterValue = "row['${parameter.displayName}']";

      if (isBool(parameter.type)) {
        return 'toBool($parameterValue as int)';
      } else if (isString(parameter.type)) {
        return '$parameterValue as String';
      } else if (isInt(parameter.type)) {
        return '$parameterValue as int';
      } else if (isDouble(parameter.type)) {
        return '$parameterValue as double';
      }
    }).join(', ');

    return '${type.displayName}($parameterValues)';
  }

  void _assertReturnsFuture(QueryMethod queryMethod) {
    if (!queryMethod.rawReturnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError('All queries have to return a Future.',
          element: queryMethod.method);
    }
  }

  void _assertReturnsEntity(QueryMethod queryMethod) {
    if (!queryMethod.returnsEntity(library)) {
      throw InvalidGenerationSourceError('The return type is not an entity.',
          element: queryMethod.method);
    }
  }
}
