// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart';

extension DartObjectExtension on DartObject {
  /// get the String representation of the enum value,
  /// or `null` if the enum was not valid
  String? toEnumValueString() {
    final interfaceType = type as InterfaceType;
    final enumName = interfaceType.getDisplayString(withNullability: false);
    final enumValue = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .map((fieldElement) => fieldElement.name)
        .singleWhereOrNull((valueName) => getField(valueName) != null);
    if (enumValue == null) {
      return null;
    } else {
      return '$enumName.$enumValue';
    }
  }

  /// get the ForeignKeyAction this enum represents,
  /// or the result of `null` if the enum did not contain a valid value
  ForeignKeyAction? toForeignKeyAction() {
    final enumValueString = toEnumValueString();
    if (enumValueString == null) {
      return null;
    } else {
      return ForeignKeyAction.values.singleWhereOrNull(
          (foreignKeyAction) => foreignKeyAction.toString() == enumValueString);
    }
  }
}
