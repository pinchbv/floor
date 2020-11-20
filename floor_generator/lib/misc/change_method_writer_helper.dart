// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/value_object/change_method.dart';

class ChangeMethodWriterHelper {
  final ChangeMethod _changeMethod;

  ChangeMethodWriterHelper(final ChangeMethod changeMethod)
      : _changeMethod = changeMethod;

  /// Adds the change method signature to the [MethodBuilder].
  void addChangeMethodSignature(final MethodBuilder methodBuilder) {
    methodBuilder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(_changeMethod.returnType.getDisplayString(
        withNullability: false,
      ))
      ..name = _changeMethod.name
      ..requiredParameters.add(_generateParameter());

    if (_changeMethod.requiresAsyncModifier) {
      methodBuilder..modifier = MethodModifier.async;
    }
  }

  Parameter _generateParameter() {
    final parameter = _changeMethod.parameterElement;

    return Parameter((builder) => builder
      ..name = parameter.name
      ..type = refer(parameter.type.getDisplayString(withNullability: false)));
  }
}
