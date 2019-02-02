import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodWriter implements Writer {
  final LibraryReader library;
  final UpdateMethod updateMethod;

  UpdateMethodWriter(this.library, this.updateMethod);

  @override
  Method write() {
    return _generateUpdateMethod();
  }

  Method _generateUpdateMethod() {
    // TODO assert is entity

    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(updateMethod.returnType.displayName)
      ..name = updateMethod.name
      ..requiredParameters.add(_generateParameter())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  Parameter _generateParameter() {
    final parameter = updateMethod.parameter;

    return Parameter((builder) => builder
      ..name = parameter.name
      ..type = refer(parameter.type.displayName));
  }

  String _generateMethodBody() {
    final parameter = updateMethod.parameter;
    final methodHeadParameterName = parameter.displayName;

    final keyValueList = (parameter.type.element as ClassElement)
        .constructors
        .first
        .parameters
        .map((parameter) {
      final valueMapping = _getValueMapping(parameter, methodHeadParameterName);

      return "'${parameter.displayName}': $valueMapping";
    }).join(', ');

    final entity = updateMethod.getEntity(library);

    // TODO exclude id?
    return '''
    final values = <String, dynamic>{
      $keyValueList
    };
    await this.database.update('${entity.name}', values);
    ''';
  }

  String _getValueMapping(
    ParameterElement parameter,
    String methodParameterName,
  ) {
    final parameterName = parameter.displayName;

    if (isBool(parameter.type)) {
      return '$methodParameterName.$parameterName ? 1 : 0';
    } else {
      return '$methodParameterName.$parameterName';
    }
  }
}
