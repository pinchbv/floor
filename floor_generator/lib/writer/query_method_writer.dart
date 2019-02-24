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

  const QueryMethodWriter(final this.library, final this.queryMethod);

  @override
  Method write() {
    return _generateQueryMethod();
  }

  Method _generateQueryMethod() {
    _assertReturnsFuture();
    _assertQueryParameters();

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

  String _generateConstructorCall(final DartType type) {
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
    final DartType parameterType,
    final String parameterValue,
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
    if (queryMethod.returnsVoid) {
      return "await database.rawQuery('${queryMethod.query}');";
    }

    _assertReturnsEntity();
    return '''
    final rows = await database.rawQuery('${queryMethod.query}');
    ${_generateMapping()}
    ''';
  }

  void _assertQueryParameters() {
    final queryParameterNames = queryMethod.queryParameterNames;
    final methodSignatureParameterNames =
        queryMethod.parameters.map((parameter) => parameter.name).toList();

    final sameAmountParameters =
        queryParameterNames.length == methodSignatureParameterNames.length;

    final allParametersAreAvailable = queryParameterNames.every(
        (parameterName) =>
            methodSignatureParameterNames.any((name) => name == parameterName));

    if (!allParametersAreAvailable || !sameAmountParameters) {
      throw InvalidGenerationSourceError(
        "Parameters of method signature don't match with parameters in the query.",
        element: queryMethod.method,
      );
    }
  }

  void _assertReturnsFuture() {
    if (!queryMethod.rawReturnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        'All queries have to return a Future.',
        element: queryMethod.method,
      );
    }
  }

  void _assertReturnsEntity() {
    if (!queryMethod.returnsEntity(library)) {
      throw InvalidGenerationSourceError(
        'The return type is not an entity.',
        element: queryMethod.method,
      );
    }
  }
}
