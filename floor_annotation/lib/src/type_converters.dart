/// Specifies additional type converters that Floor can use.
/// The TypeConverter is added to the scope of the element so if you put it on
/// a class, all methods/fields in that class will be able to use the
/// converters.
///
/// Type converters can be applied to:
/// 1. databases
/// 1. DAOs
/// 1. entities
/// 1. entity fields
/// 1. DAO methods
/// 1. DAO method parameters
class TypeConverters {
  /// The list of type converter classes.
  final List<Type> value;

  const TypeConverters(this.value);
}
