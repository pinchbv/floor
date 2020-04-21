import 'package:analyzer/dart/element/type.dart';

class TypeConverter {
  final String name;
  final DartType fieldType;
  final DartType databaseType;
  final TypeConverterScope scope;

  TypeConverter(this.name, this.fieldType, this.databaseType, this.scope);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeConverter &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          fieldType == other.fieldType &&
          databaseType == other.databaseType &&
          scope == other.scope;

  @override
  int get hashCode =>
      name.hashCode ^
      fieldType.hashCode ^
      databaseType.hashCode ^
      scope.hashCode;

  @override
  String toString() {
    // TODO #165 update
    return 'TypeConverter{name: $name, fieldType: $fieldType, databaseType: $databaseType, scope: $scope}';
  }
}

enum TypeConverterScope {
  database,
  dao,
  entity, // TODO #165 rename to queryable?
  field,
  daoMethod,
  daoMethodParameter,
}
