import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';

extension DartObjectExtension on DartObject {
  /// get the String representation of the enum value,
  /// or `null` if the enum was not valid
  String? toEnumValueString() {
    final interfaceType = type as InterfaceType;
    final enumName = interfaceType.getDisplayString(withNullability: false);
    final enumValue = getField('_name')?.toStringValue();
    if (enumValue == null) {
      return null;
    } else {
      return '$enumName.$enumValue';
    }
  }

  /// get the ForeignKeyAction this enum represents,
  /// or the result of `null` if the enum did not contain a valid value
  ForeignKeyAction? toForeignKeyAction() {
    final enumIndex = getField('index')?.toIntValue();
    return enumIndex != null ? ForeignKeyAction.values[enumIndex] : null;
  }
}
