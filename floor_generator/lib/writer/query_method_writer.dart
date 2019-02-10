import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodWriter implements Writer {
  final LibraryReader library;
  final QueryMethod queryMethod;

  const QueryMethodWriter(this.library, this.queryMethod);

  @override
  Method write() {
    return _generateQueryMethod(queryMethod);
  }

  Method _generateQueryMethod(QueryMethod queryMethod) {
    _assertReturnsFuture();
    _assertReturnsEntity();

    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(queryMethod.rawReturnType.displayName)
      ..name = queryMethod.name
      ..requiredParameters.addAll(_generateMethodParameters())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  List<Parameter> _generateMethodParameters() {
    return queryMethod.parameters.map((parameter) {
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

  String _generateMapping() {
    final constructorCall =
        _generateConstructorCall(queryMethod.flattenedReturnType);

    if (queryMethod.returnsList) {
      return 'return rows.map((row) => $constructorCall).toList();';
    } else {
      return '''
      if (rows.isEmpty) {
        return null;
      }
      final row = rows.first;
      return $constructorCall;
      ''';
    }
  }

  String _generateConstructorCall(DartType type) {
    final columnNames = queryMethod
        .getEntity(library)
        .columns
        .map((column) => column.name)
        .toList();
    final constructorParameters =
        (type.element as ClassElement).constructors.first.parameters;

    final parameterValues = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final parameterValue = "row['${columnNames[i]}']";
      final castedParameterValue =
          _castParameterValue(constructorParameters[i].type, parameterValue);

      if (castedParameterValue != null) {
        parameterValues.add(castedParameterValue);
      }
    }

    return '${type.displayName}(${parameterValues.join(', ')})';
  }

  String _castParameterValue(
    DartType parameterType,
    String parameterValue,
  ) {
    if (isBool(parameterType)) {
      return '($parameterValue as int) != 0'; // maps int to bool
    } else if (isString(parameterType)) {
      return '$parameterValue as String';
    } else if (isInt(parameterType)) {
      return '$parameterValue as int';
    } else if (isDouble(parameterType)) {
      return '$parameterValue as double';
    } else {
      return null;
    }
  }

  String _generateMethodBody() {
    final mapping = _generateMapping();

    return '''
    final rows = await database.rawQuery('${queryMethod.query}');
    $mapping
    ''';
  }

  void _assertReturnsFuture() {
    if (!queryMethod.rawReturnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError('All queries have to return a Future.',
          element: queryMethod.method);
    }
  }

  void _assertReturnsEntity() {
    if (!queryMethod.returnsEntity(library)) {
      throw InvalidGenerationSourceError('The return type is not an entity.',
          element: queryMethod.method);
    }
  }
}
