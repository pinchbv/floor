// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
extension StringUtils on String {
  /// Makes the first letter of the supplied string [value] lowercase.
  String decapitalize() {
    return '${this[0].toLowerCase()}${substring(1)}';
  }
}
