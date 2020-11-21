// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';

/// Represents an annotation as an [Expression].
class AnnotationExpression extends CodeExpression {
  final String annotation;

  AnnotationExpression(final this.annotation) : super(Code(annotation));
}

final overrideAnnotationExpression = AnnotationExpression('override');
