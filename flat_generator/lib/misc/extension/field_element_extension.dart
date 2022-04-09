import 'package:analyzer/dart/element/element.dart';
import 'package:flat_annotation/flat_annotation.dart' as annotations;
import 'package:flat_generator/misc/type_utils.dart';

extension FieldElementExtension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    return !(isStatic || isSynthetic || isIgnored);
  }

  bool isEmbedded() =>
      hasAnnotation(annotations.embedded.runtimeType) &&
      type.element is ClassElement;
}
