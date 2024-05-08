extension StringExt on String {
  bool equals(String other, {bool ignoreCase = false}) {
    return ignoreCase ? toLowerCase() == other.toLowerCase() : this == other;
  }
}
