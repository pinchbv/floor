import 'package:floor_generator/misc/annotations.dart';
import 'package:strings/strings.dart';

extension StringUtils on String {
  /// Makes the first letter of the supplied string [value] lowercase.
  @nonNull
  String decapitalize() {
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  /// Makes the first letter of the supplied string [value] lowercase.
  @nonNull
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts this string to a literal for
  /// embedding it into source code strings.
  @nonNull
  String toLiteral() {
    if (this == null) {
      return 'null';
    } else {
      return "'${escape(this)}'";
    }
  }
}
