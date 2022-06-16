import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart';

extension DartObjectExtension on DartObject {
  /// get the String representation of the enum value,
  /// or `null` if the enum was not valid
  String? toEnumValueString() {
    final interfaceType = type as InterfaceType;
    final enumName = interfaceType.getDisplayString(withNullability: false);
    final enumFields = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .toList();

    // Find the index of the matching enum constant.
    final enumIndex = _getIndex(enumFields);
    final enumValue =
        enumIndex != null ? OnConflictStrategy.values[enumIndex].name : null;

    if (enumValue == null) {
      return null;
    } else {
      return '$enumName.$enumValue';
    }
  }

  /// get the ForeignKeyAction this enum represents,
  /// or the result of `null` if the enum did not contain a valid value
  ForeignKeyAction? toForeignKeyAction() {
    final interfaceType = type as InterfaceType;
    final enumFields = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .toList();

    // Find the index of the matching enum constant.
    final enumIndex = _getIndex(enumFields);
    return enumIndex != null ? ForeignKeyAction.values[enumIndex] : null;
  }

  int? _getIndex(List<FieldElement> enumFields) => enumFields
      .asMap()
      .entries
      .firstWhereOrNull((e) => e.value.computeConstantValue() == this)
      ?.key;
}
