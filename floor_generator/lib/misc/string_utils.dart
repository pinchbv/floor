extension StringUtils on String {
  /// Makes the first letter of the supplied string [value] lowercase.
  String decapitalize() {
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  /// Makes the first letter of the supplied string [value] lowercase.
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
