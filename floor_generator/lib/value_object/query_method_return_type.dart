import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/queryable.dart';

/// A simple accessor class for providing all properties of
/// the return type of a query method.
class QueryMethodReturnType {
  final DartType raw;

  /*late*/ Queryable queryable;
  // The following values are derived once (in the constructor) and stored.
  final bool isStream;
  final bool isFuture;
  final bool isList;

  /// Flattened return type.
  ///
  /// E.g.
  /// Future<T> -> T,
  /// Future<List<T>> -> T
  ///
  /// Stream<T> -> T
  /// Stream<List<T>> -> T
  @nonNull
  final DartType flattened;

  @nonNull
  bool get isVoid => flattened.isVoid;

  @nonNull
  bool get isPrimitive =>
      flattened.isVoid ||
      flattened.isDartCoreDouble ||
      flattened.isDartCoreInt ||
      flattened.isDartCoreBool ||
      flattened.isDartCoreString ||
      flattened.isUint8List;

  QueryMethodReturnType(this.raw)
      : assert(raw != null),
        isStream = raw.isStream,
        isFuture = raw.isDartAsyncFuture,
        isList = raw.flatten().isDartCoreList,
        flattened = _flattenWithList(raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryMethodReturnType &&
          runtimeType == other.runtimeType &&
          raw == other.raw &&
          queryable == other.queryable;

  @override
  int get hashCode => raw.hashCode ^ queryable.hashCode;

  @override
  String toString() {
    return 'QueryMethod{raw: $raw, queryable: $queryable, flattened: $flattened}';
  }

  @nonNull
  static DartType _flattenWithList(DartType rawReturnType) {
    final flattenedOnce = rawReturnType.flatten();
    if (flattenedOnce.isDartCoreList) {
      return flattenedOnce.flatten();
    } else {
      return flattenedOnce;
    }
  }
}
