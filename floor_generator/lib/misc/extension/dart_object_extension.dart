import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:meta/meta.dart';

extension DartObjectExtension on DartObject {
  /// get the String representation of the enum value, or the result of
  /// [orElse] if the enum was not valid.
  String toEnumValueString({@required String orElse()}) {
    final interfaceType = type as InterfaceType;
    final enumValue = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .map((fieldElement) => fieldElement.name)
        .singleWhere((valueName) => getField(valueName) != null,
            orElse: () => null);
    if (enumValue == null) {
      return orElse();
    } else {
      return '$interfaceType.$enumValue';
    }
  }

  /// get the ForeignKeyAction this enum represents, or the result of
  /// [orElse] if the enum did not contain a valid value.
  ForeignKeyAction toForeignKeyAction({@required ForeignKeyAction orElse()}) {
    final enumValueString = toEnumValueString(orElse: () => null);
    if (enumValueString == null) {
      return orElse();
    } else {
      return ForeignKeyAction.values.singleWhere(
          (foreignKeyAction) => foreignKeyAction.toString() == enumValueString,
          orElse: orElse);
    }
  }
}
