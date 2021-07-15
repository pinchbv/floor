import 'package:collection/collection.dart';

const String varlistPlaceholder = ':varlist';

class Query {
  final String sql;
  final List<ListParameter> listParameters;

  Query(this.sql, this.listParameters);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          runtimeType == other.runtimeType &&
          sql == other.sql &&
          const ListEquality<ListParameter>()
              .equals(listParameters, other.listParameters);

  @override
  int get hashCode => sql.hashCode ^ listParameters.hashCode;

  @override
  String toString() {
    return 'Query{sql: $sql, listParameters: $listParameters}';
  }
}

class ListParameter {
  final int position;
  final String name;

  ListParameter(this.position, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListParameter &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          name == other.name;

  @override
  int get hashCode => position.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'ListParameter{position: $position, name: $name}';
  }
}
