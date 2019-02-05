import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/model/change_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class ChangeMethodWriter implements Writer {
  final LibraryReader library;
  final ChangeMethod method;
  final Writer adapterWriter;

  ChangeMethodWriter(this.library, this.method, this.adapterWriter);

  @override
  Method write() {
    _assertChangesEntity();
    return _generateChangeMethod();
  }

  Method _generateChangeMethod() {
    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(method.returnType.displayName)
      ..name = method.name
      ..requiredParameters.add(_generateParameter())
      ..modifier = MethodModifier.async
      ..body = adapterWriter.write());
  }

  Parameter _generateParameter() {
    final parameter = method.parameter;

    return Parameter((builder) => builder
      ..name = parameter.name
      ..type = refer(parameter.type.displayName));
  }

  void _assertChangesEntity() {
    if (!method.changesEntity(library)) {
      throw InvalidGenerationSourceError(
        'You are trying to change an object which is not an entity.',
        element: method.method,
      );
    }
  }
}
