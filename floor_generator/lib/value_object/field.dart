import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';

/// Represents an Entity field and thus a table column.
class Field {
  final FieldElement fieldElement;
  final String name;
  final String columnName;
  final bool isNullable;
  final bool isIgnored;
  final String sqlType;

  Field(
    this.fieldElement,
    this.name,
    this.columnName,
    this.isNullable,
    this.isIgnored,
    this.sqlType,
  );

  /// The database column definition.
  @nonNull
  String getDatabaseDefinition(final bool autoGenerate) {
    final columnSpecification = StringBuffer();

    if (autoGenerate) {
      columnSpecification.write(' PRIMARY KEY AUTOINCREMENT');
    }
    if (!isNullable) {
      columnSpecification.write(' NOT NULL');
    }

    return '`$columnName` $sqlType$columnSpecification';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Field &&
          runtimeType == other.runtimeType &&
          fieldElement == other.fieldElement &&
          name == other.name &&
          columnName == other.columnName &&
          isNullable == other.isNullable &&
          isIgnored == other.isIgnored &&
          sqlType == other.sqlType;

  @override
  int get hashCode =>
      fieldElement.hashCode ^
      name.hashCode ^
      columnName.hashCode ^
      isNullable.hashCode ^
      isIgnored.hashCode ^
      sqlType.hashCode;

  @override
  String toString() {
    return 'Field{fieldElement: $fieldElement, name: $name, columnName: $columnName, isNullable: $isNullable, isIgnored: $isIgnored, sqlType: $sqlType}';
  }
}
