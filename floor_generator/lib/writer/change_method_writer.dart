import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/model/change_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class ChangeMethodWriter implements Writer {
  final LibraryReader library;
  final ChangeMethod method;
  final Writer methodBodyWriter;

  ChangeMethodWriter(this.library, this.method, this.methodBodyWriter);

  @override
  Method write() {
    _assertChangesEntity();
    return _generateChangeMethod();
  }

  Method _generateChangeMethod() {
    final builder = MethodBuilder()
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(method.returnType.displayName)
      ..name = method.name
      ..requiredParameters.add(_generateParameter())
      ..body = methodBodyWriter.write();

    if (method.requiresAsyncModifier) {
      builder..modifier = MethodModifier.async;
    }

    return builder.build();
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
