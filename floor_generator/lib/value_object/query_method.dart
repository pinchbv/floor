import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';

/// Wraps a method annotated with Query
/// to enable easy access to code generation relevant data.
class QueryMethod {
  final MethodElement methodElement;

  final String name;

  /// Query where ':' got replaced with '$'.
  final String? query;

  final DartType rawReturnType;

  /// Flattened return type.
  ///
  /// E.g.
  /// Future<T> -> T,
  /// Future<List<T>> -> T
  ///
  /// Stream<T> -> T
  /// Stream<List<T>> -> T
  final DartType flattenedReturnType;

  final List<ParameterElement> parameters;

  final Queryable? queryable;

  final Set<TypeConverter> typeConverters;

  // final bool isRawQuery;

  QueryMethod(
    this.methodElement,
    this.name,
    this.query,
    this.rawReturnType,
    this.flattenedReturnType,
    this.parameters,
    this.queryable,
    this.typeConverters,
  );

  bool get returnsList {
    final type = returnsStream
        ? rawReturnType.flatten()
        : methodElement.library.typeSystem.flatten(rawReturnType);

    return type.isDartCoreList;
  }

  bool get returnsStream => rawReturnType.isStream;

  bool get returnsVoid => flattenedReturnType.isVoid;

  @override
  String toString() {
    return 'QueryMethod{methodElement: $methodElement, name: $name, query: $query, rawReturnType: $rawReturnType, flattenedReturnType: $flattenedReturnType, parameters: $parameters, queryable: $queryable, typeConverters: $typeConverters}';
  }
}
