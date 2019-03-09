/// Makes the first letter of the supplied [value] string lowercase.
String decapitalize(final String value) {
  return '${value[0].toLowerCase()}${value.substring(1)}';
}
