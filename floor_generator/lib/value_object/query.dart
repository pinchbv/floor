import 'package:collection/collection.dart';

const String varlistPlaceholder = ':varlist';

class Query {
  final String sql;
  final List<QueryParameter> queryParameters;

  Query(this.sql, this.queryParameters);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          runtimeType == other.runtimeType &&
          sql == other.sql &&
          const ListEquality<QueryParameter>()
              .equals(queryParameters, other.queryParameters);

  @override
  int get hashCode => sql.hashCode ^ queryParameters.hashCode;

  @override
  String toString() {
    return 'Query{sql: $sql, listParameters: $queryParameters}';
  }
}

class QueryParameter {
  final int position;
  final String name;
  final ParamType type;

  QueryParameter(this.position, this.name, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryParameter &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => position.hashCode ^ name.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'ListParameter{position: $position, name: $name, type: $type}';
  }
}

// Parameter type
enum ParamType {
  normal,list,custom
}
