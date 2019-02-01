import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class InsertMethodWriter implements Writer {
  final LibraryReader library;
  final InsertMethod insertMethod;

  InsertMethodWriter(this.library, this.insertMethod);

  @override
  Method write() {
    return _generateInsertMethod();
  }

  Method _generateInsertMethod() {
    _assertInsertsEntity();

    return Method((builder) => builder
      ..annotations.add(AnnotationExpression('override'))
      ..returns = refer(insertMethod.returnType.displayName)
      ..name = insertMethod.name
      ..requiredParameters.add(_generateParameter())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  Parameter _generateParameter() {
    final parameter = insertMethod.parameter;

    return Parameter((builder) => builder
      ..name = parameter.name
      ..type = refer(parameter.type.displayName));
  }

  String _generateMethodBody() {
    final parameter = insertMethod.parameter;
    final methodHeadParameterName = parameter.displayName;

    final keyValueList = (parameter.type.element as ClassElement)
        .constructors
        .first
        .parameters
        .map((parameter) {
      final valueMapping = _getValueMapping(parameter, methodHeadParameterName);

      return "'${parameter.displayName}': $valueMapping";
    }).join(', ');

    final entity = insertMethod.getEntity(library);

    // TODO exclude id?
    return '''
    final values = <String, dynamic>{
      $keyValueList
    };
    await this.database.insert('${entity.name}', values);
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

  void _assertInsertsEntity() {
    if (!insertMethod.insertsEntity(library)) {
      throw InvalidGenerationSourceError(
        'You are trying to insert an object which is not an entity.',
        element: insertMethod.method,
      );
    }
  }
}
