import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class DeleteMethodWriter implements Writer {
  final LibraryReader library;
  final DeleteMethod deleteMethod;

  DeleteMethodWriter(this.library, this.deleteMethod);

  @override
  Method write() {
    return _generateDeleteMethod();
  }

  Method _generateDeleteMethod() {
    // TODO assert deletes entity

    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(deleteMethod.returnType.displayName)
      ..name = deleteMethod.name
      ..requiredParameters.add(_generateParameter())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  Parameter _generateParameter() {
    final parameter = deleteMethod.parameter;

    return Parameter((builder) => builder
      ..name = parameter.name
      ..type = refer(parameter.type.displayName));
  }

  String _generateMethodBody() {
    final entity = deleteMethod.getEntity(library);
    final primaryKeyColumn =
        entity.columns.firstWhere((column) => column.isPrimaryKey);
    final methodHeadParameterName = deleteMethod.parameter.name;

    return '''
    await this.database.rawDelete('DELETE FROM ${entity.name} WHERE ${primaryKeyColumn.name} = \${$methodHeadParameterName.${primaryKeyColumn.field.displayName}}');
    ''';
  }
}
