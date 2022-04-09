import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/value_object/type_converter.dart';

/// Represents an Entity field and thus a table column.
class Field extends FieldBase {
  final String columnName;
  final bool isNullable;
  final String sqlType;
  final TypeConverter? typeConverter;

  Field(
    FieldElement fieldElement,
    String name,
    this.columnName,
    this.isNullable,
    this.sqlType,
    this.typeConverter,
  ) : super(fieldElement, name);

  /// The database column definition.
  String getDatabaseDefinition(
      {required final bool autoGenerate, final bool forceNullability = false}) {
    final columnSpecification = StringBuffer();

    if (autoGenerate) {
      columnSpecification.write(' PRIMARY KEY AUTOINCREMENT');
    }
    if (!isNullable && !forceNullability) {
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
          sqlType == other.sqlType &&
          typeConverter == other.typeConverter;

  @override
  int get hashCode =>
      fieldElement.hashCode ^
      name.hashCode ^
      columnName.hashCode ^
      isNullable.hashCode ^
      sqlType.hashCode ^
      typeConverter.hashCode;

  @override
  String toString() {
    return 'Field{fieldElement: $fieldElement, name: $name, columnName: $columnName, isNullable: $isNullable, sqlType: $sqlType, typeConverter: $typeConverter}';
  }
}

class FieldBase {
  final FieldElement fieldElement;
  final String name;

  FieldBase(this.fieldElement, this.name);
}
