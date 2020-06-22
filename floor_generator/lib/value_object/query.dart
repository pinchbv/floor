import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:sqlparser/sqlparser.dart';

class Query {
  final String sql;

  final List<ListParameter> listParameters;

  final List<SqlResultColumn> resultColumnTypes;

  /// The entities this query directly and indirectly depends on.
  /// If an entity of this set changes, it is possible that the output of
  /// this query also changes.
  final Set<Entity> dependencies;

  /// The names of the entities this query will change directly
  final Set<String> affectedEntities;

  Query(this.sql, this.listParameters, this.resultColumnTypes,
      this.dependencies, this.affectedEntities);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Query &&
          runtimeType == other.runtimeType &&
          sql == other.sql &&
          const ListEquality<ListParameter>()
              .equals(listParameters, other.listParameters) &&
          const ListEquality<SqlResultColumn>()
              .equals(resultColumnTypes, other.resultColumnTypes) &&
          const SetEquality<Entity>()
              .equals(dependencies, other.dependencies) &&
          const SetEquality<String>()
              .equals(affectedEntities, other.affectedEntities);

  @override
  int get hashCode =>
      sql.hashCode ^
      listParameters.hashCode ^
      resultColumnTypes.hashCode ^
      dependencies.hashCode ^
      affectedEntities.hashCode;

  @override
  String toString() {
    return 'Query{sql: $sql, listParameters: $listParameters, resultColumnTypes: $resultColumnTypes, dependencies: $dependencies, affectedEntities: $affectedEntities}';
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

class SqlResultColumn {
  @nonNull
  final String name;

  @nullable
  final BasicType sqltype;

  @nullable
  final bool isNullable;

  @nonNull
  //TODO reminder:check for all accesses
  final bool isResolved;

  SqlResultColumn(this.name, ResolveResult type)
      : assert(type != null),
        sqltype = type.type?.type,
        isNullable = type.type?.nullable,
        isResolved = !type.unknown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SqlResultColumn &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          sqltype == other.sqltype &&
          isNullable == other.isNullable &&
          isResolved == other.isResolved;

  @override
  int get hashCode =>
      name.hashCode ^
      sqltype.hashCode ^
      isNullable.hashCode ^
      isResolved.hashCode;

  @override
  String toString() {
    return 'SqlResultColumn{name: $name, sqltype: $sqltype, isNullable: $isNullable, isResolved: $isResolved}';
  }
}
