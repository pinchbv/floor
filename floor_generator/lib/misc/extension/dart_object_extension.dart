import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:meta/meta.dart';

extension DartObjectExtension on DartObject {
  /// get the String representation of the enum value, or the result of
  /// [orElse] if the enum was not valid. [orElse]
  String toEnumValueString({@required String orElse()}) {
    final interfaceType = type as InterfaceType;
    final enumValue = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .map((fieldElement) => fieldElement.name)
        .singleWhere((valueName) => getField(valueName) != null,
            orElse: orElse);

    return '$interfaceType.$enumValue';
  }

  ForeignKeyAction toForeignKeyAction({@required ForeignKeyAction orElse()}) {
    final enumValueString = toEnumValueString(orElse: () => null);
    return ForeignKeyAction.values.singleWhere(
        (foreignKeyAction) => foreignKeyAction.toString() == enumValueString,
        orElse: orElse);
  }
}
