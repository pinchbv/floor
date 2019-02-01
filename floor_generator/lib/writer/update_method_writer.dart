import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
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
    final entity = updateMethod.getEntity(library);
    final primaryKeyColumn =
        entity.columns.firstWhere((column) => column.isPrimaryKey);
    final methodHeadParameterName = updateMethod.parameter.name;

    return '''
    await this.database.rawDelete('DELETE FROM ${entity.name} WHERE ${primaryKeyColumn.name} = \${$methodHeadParameterName.${primaryKeyColumn.field.displayName}}');
    ''';
  }
}
