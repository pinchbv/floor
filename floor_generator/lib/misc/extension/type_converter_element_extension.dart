import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:floor_generator/processor/type_converter_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';

extension TypeConverterElementExtension on Element {
  /// Returns a set of [TypeConverter]s found in the @TypeConverters
  /// annotation on this element
  Set<TypeConverter> getTypeConverters(final TypeConverterScope scope) {
    if (hasAnnotation(annotations.TypeConverters)) {
      final typeConverterElements = getAnnotation(annotations.TypeConverters)
          ?.getField(AnnotationField.typeConverterValue)
          ?.toListValue()
          ?.mapNotNull((object) => object.toTypeValue()?.element2);

      if (typeConverterElements == null || typeConverterElements.isEmpty) {
        throw ProcessorError(
          message:
              'There are no type converts defined even though the @TypeConverters annotation is used.',
          todo: 'Supply a type converter class to the annotation.',
          element: this,
        );
      }

      final typeConverterClassElements =
          typeConverterElements.cast<ClassElement>();

      if (typeConverterClassElements
          .any((element) => !element.isTypeConverter)) {
        throw ProcessorError(
          message:
              'Only classes that inherit from TypeConverter can be used as type converters.',
          todo: 'Make sure use a class that inherits from TypeConverter.',
          element: this,
        );
      }

      return typeConverterClassElements
          .map((element) => TypeConverterProcessor(element, scope).process())
          .toSet();
    } else {
      return {};
    }
  }
}

extension on ClassElement {
  bool get isTypeConverter =>
      supertype?.element2.displayName == 'TypeConverter';
}
