import 'package:code_builder/code_builder.dart';

/// Represents an annotation as an [Expression].
class AnnotationExpression extends CodeExpression {
  final String annotation;

  AnnotationExpression(this.annotation) : super(Code(annotation));
}

final overrideAnnotationExpression = AnnotationExpression('override');
