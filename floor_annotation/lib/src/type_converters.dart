import 'package:meta/meta.dart';

/// Specifies additional type converters that Floor can use.
/// The TypeConverter is added to the scope of the element so if you put it on
/// a class, all methods/fields in that class will be able to use the
/// converter.
///
/// **The closest type converter wins!**
/// If you, for example, add a converter on the database level and another one
/// on a DAO method parameter, which takes care of converting the same types,
/// the one declared next to the DAO method parameter will be used.
/// Please refer to the below list to get more information about the
/// precedence of converters.
///
/// Type converters can be applied to:
/// 1. databases
/// 1. DAOs
/// 1. entities/views
/// 1. entity/view fields
/// 1. DAO methods
/// 1. DAO method parameters
@experimental
class TypeConverters {
  /// The list of type converter classes.
  final List<Type>? value;

  const TypeConverters(this.value);
}
