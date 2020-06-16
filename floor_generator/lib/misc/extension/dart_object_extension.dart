import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';

import '../annotations.dart';

extension DartObjectExtension on DartObject {
  String toEnumValueString() {
    final interfaceType = type as InterfaceType;
    final enumValue = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .map((fieldElement) => fieldElement.name)
        .singleWhere((valueName) => getField(valueName) != null,
            orElse: () => null);

    return '$interfaceType.$enumValue';
  }

  @nullable
  ForeignKeyAction toForeignKeyAction() {
    final enumValueString = toEnumValueString();
    return ForeignKeyAction.values.singleWhere(
        (foreignKeyAction) => foreignKeyAction.toString() == enumValueString,
        orElse: () => null);
  }
}
