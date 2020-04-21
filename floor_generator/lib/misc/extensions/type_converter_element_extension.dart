import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/type_converter_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';

import '../annotations.dart';

// TODO #165 proper name
extension TypeConverterElement on Element {
  @nonNull
  List<TypeConverter> getTypeConverters(final TypeConverterScope scope) {
    if (hasAnnotation(annotations.TypeConverters)) {
      return getAnnotation(annotations.TypeConverters)
              .getField(AnnotationField.typeConverterValue)
              ?.toListValue()
              ?.map((object) => object.toTypeValue().element)
              ?.whereType<ClassElement>() // TODO #165 throw when not class
              ?.where((element) =>
                  element.isTypeConverter) // TODO #165 throw when not
              ?.map(
                  (element) => TypeConverterProcessor(element, scope).process())
              ?.toList() ??
          [];
    } else {
      return [];
    }
  }
}

extension on ClassElement {
  bool get isTypeConverter => supertype.element.displayName == 'TypeConverter';
}
