import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';

/// Wraps a method annotated with Query
/// to enable easy access to code generation relevant data.
class QueryMethod {
  final MethodElement methodElement;

  final String name;

  /// The annotated and analyzed Query
  final Query query;

  final QueryMethodReturnType returnType;

  final List<ParameterElement> parameters;

  QueryMethod(
    this.methodElement,
    this.name,
    this.query,
    this.returnType,
    this.parameters,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryMethod &&
          runtimeType == other.runtimeType &&
          methodElement == other.methodElement &&
          name == other.name &&
          query == other.query &&
          returnType == other.returnType &&
          const ListEquality<ParameterElement>()
              .equals(parameters, other.parameters);

  @override
  int get hashCode =>
      methodElement.hashCode ^
      name.hashCode ^
      query.hashCode ^
      returnType.hashCode ^
      parameters.hashCode;

  @override
  String toString() {
    return 'QueryMethod{methodElement: $methodElement, name: $name, query: $query, returnType: $returnType, parameters: $parameters}';
  }
}
