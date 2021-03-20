/// An annotation used to specify how a enum value is saved.
class EnumValue {
  /// The value to use when save and load.
  ///
  /// Can be a [String] or an [int].
  final dynamic value;

  const EnumValue(this.value);
}
