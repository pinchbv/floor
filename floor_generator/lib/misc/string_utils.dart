/// Makes the first letter of the supplied string [value] lowercase.
String decapitalize(final String value) {
  return '${value[0].toLowerCase()}${value.substring(1)}';
}

extension on String {
  String decapitalize() {
    return '${this[0].toLowerCase()}${substring(1)}';
  }
}
