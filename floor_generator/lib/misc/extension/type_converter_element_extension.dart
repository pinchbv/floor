// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/type_converter_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

extension TypeConverterElementExtension on Element {
  /// Returns a set of [TypeConverter]s found in the @TypeConverters
  /// annotation on this element
  Set<TypeConverter> getTypeConverters(final TypeConverterScope scope) {
    if (hasAnnotation(annotations.TypeConverters)) {
      final typeConverterElements = getAnnotation(annotations.TypeConverters)
          .getField(AnnotationField.typeConverterValue)
          ?.toListValue()
          ?.map((object) => object.toTypeValue()!.element);

      if (typeConverterElements == null || typeConverterElements.isEmpty) {
        throw InvalidGenerationSourceError(
            'There are no type converts defined even though the @TypeConverters annotation is used.',
            todo: 'Supply a type converter class to the annotation.',
            element: this);
      }

      final typeConverterClassElements =
          typeConverterElements.cast<ClassElement>();

      if (typeConverterClassElements
          .any((element) => !element.isTypeConverter)) {
        throw InvalidGenerationSourceError(
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
  bool get isTypeConverter => supertype?.element.displayName == 'TypeConverter';
}
