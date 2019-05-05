import 'package:analyzer/dart/element/element.dart';

/// Represents an Entity field and thus a table column.
class Field {
  final FieldElement fieldElement;
  final String name;
  final String columnName;
  final bool isNullable;
  final bool readOnly;
  final bool isPrimaryKey;
  final String sqlType;

  Field(
    this.fieldElement,
    this.name,
    this.columnName,
    this.isNullable,
    this.readOnly,
    this.isPrimaryKey,
    this.sqlType,
  );

  /// The database column definition.
  String getDatabaseDefinition(final bool autoGenerate) {
    final columnSpecification = StringBuffer();

    if (isPrimaryKey) {
      columnSpecification.write(' PRIMARY KEY');
    }
    if (autoGenerate) {
      columnSpecification.write(' AUTOINCREMENT');
    }
    if (!isNullable || isPrimaryKey) {
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
          readOnly == other.readOnly &&
          isPrimaryKey == other.isPrimaryKey &&
          sqlType == other.sqlType;

  @override
  int get hashCode =>
      fieldElement.hashCode ^
      name.hashCode ^
      columnName.hashCode ^
      isNullable.hashCode ^
      readOnly.hashCode ^
      isPrimaryKey.hashCode ^
      sqlType.hashCode;

  @override
  String toString() {
    return 'Field{fieldElement: $fieldElement, name: $name, columnName: $columnName, isNullable: $isNullable, readOnly: $readOnly, isPrimaryKey: $isPrimaryKey, sqlType: $sqlType}';
  }
}
