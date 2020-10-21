import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartObjectExtension on DartObject {
  String toEnumValueString() {
    final interfaceType = type as InterfaceType;
    final enumName = interfaceType.getDisplayString(withNullability: false);
    final enumValue = interfaceType.element.fields
        .where((element) => element.isEnumConstant)
        .map((fieldElement) => fieldElement.name)
        .singleWhere((valueName) => getField(valueName) != null);

    return '$enumName.$enumValue';
  }
}
