import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:strings/strings.dart';

extension StringExtension on String {
  /// Returns a copy of this string having its first letter lowercased, or the
  /// original string, if it's empty or already starts with a lower case letter.
  ///
  /// ```dart
  /// print('abcd'.decapitalize()) // abcd
  /// print('Abcd'.decapitalize()) // abcd
  /// ```
  String decapitalize() {
    switch (length) {
      case 0:
        return this;
      case 1:
        return toLowerCase();
      default:
        return this[0].toLowerCase() + substring(1);
    }
  }

  /// Returns a copy of this string having its first letter uppercased, or the
  /// original string, if it's empty or already starts with a upper case letter.
  ///
  /// ```dart
  /// print('abcd'.capitalize()) // Abcd
  /// print('Abcd'.capitalize()) // Abcd
  /// ```
  String capitalize() {
    switch (length) {
      case 0:
        return this;
      case 1:
        return toUpperCase();
      default:
        return this[0].toUpperCase() + substring(1);
    }
  }
}

extension NullableStringExtension on String? {
  /// Converts this string to a literal for
  /// embedding it into source code strings.
  ///
  /// ```dart
  /// print(null.toLiteral())   // null
  /// print('Abcd'.toLiteral()) // 'Abcd'
  /// ```
  String toLiteral() {
    if (this == null) {
      return 'null';
    } else {
      return "'${this!.toEscaped()}'";
    }
  }
}

extension CastStringExtension on String {
  String cast(DartType dartType, Element? parameterElement,
      {bool withNullability = true}) {
    if (dartType.isDartCoreBool) {
      final booleanDeserializer = '($this as int) != 0';
      if (dartType.isNullable && withNullability) {
        // if the value is null, return null
        // if the value is not null, interpret 1 as true and 0 as false
        return '$this == null ? null : $booleanDeserializer';
      } else {
        return booleanDeserializer;
      }
    } else if (dartType.isEnumType) {
      final typeString = dartType.getDisplayString(withNullability: false);
      final enumDeserializer = '$typeString.values[$this as int]';
      if (dartType.isNullable && withNullability) {
        return '$this == null ? null : $enumDeserializer';
      } else {
        return enumDeserializer;
      }
    } else if (dartType.isDartCoreString ||
        dartType.isDartCoreInt ||
        dartType.isUint8List ||
        dartType.isDartCoreDouble) {
      final typeString = dartType.getDisplayString(
        withNullability: withNullability,
      );
      return '$this as $typeString';
    } else {
      throw InvalidGenerationSourceError(
        'Trying to convert unsupported type $dartType.',
        todo: 'Consider adding a type converter.',
        element: parameterElement,
      );
    }
  }
}
