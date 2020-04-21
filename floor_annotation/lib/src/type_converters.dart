/// Specifies additional type converters that Floor can use.
/// The TypeConverter is added to the scope of the element so if you put it on
/// a class / interface, all methods / fields in that class will be able to use
/// the converters.
class TypeConverters {
  // TODO #165 update documentation
  /// The list of type converter classes.
  final List<Type> value;

  const TypeConverters(this.value);
}
