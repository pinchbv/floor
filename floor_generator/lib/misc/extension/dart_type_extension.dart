import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  // TODO #375 test
  bool get isNullable {
    switch (nullabilitySuffix) {
      case NullabilitySuffix.question:
      case NullabilitySuffix.star: // support legacy code without non-nullables
        return true;
      case NullabilitySuffix.none:
        return false;
    }
  }
}
