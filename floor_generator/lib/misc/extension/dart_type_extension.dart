// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  // TODO #375 test and decide for one implementation
  bool get isNullable {
    return element.library.typeSystem.isNullable(this);

    // final nullabilitySuffix = this.nullabilitySuffix;
    // switch (nullabilitySuffix) {
    //   case NullabilitySuffix.question:
    //   case NullabilitySuffix.star: // support legacy code without non-nullables
    //     return true;
    //   case NullabilitySuffix.none:
    //     return false;
    // }
  }
}
