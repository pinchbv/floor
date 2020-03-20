extension StringUtils on String {
  /// Makes the first letter of the supplied string [value] lowercase.
  String decapitalize() {
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  /// Flattens a multiline string into a single line string by concatenating
  /// lines separated by a space and remove leading and trailing whitespace
  String flatten() {
    return replaceAll('\n', ' ').replaceAll(RegExp(r'[ ]{2,}'), ' ').trim();
  }
}
