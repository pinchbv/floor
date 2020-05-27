import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';

extension FieldElementExtension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    return !(isStatic || isSynthetic || isIgnored || isEmbedded);
  }

  bool get isEmbedded {
    return hasAnnotation(annotations.Embedded) && type.element is ClassElement;
  }
}
