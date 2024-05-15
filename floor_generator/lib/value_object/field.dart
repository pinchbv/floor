import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/embed.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

/// Represents an Entity field and thus a table column.
class Field {
  final FieldElement fieldElement;
  final String name;
  final String columnName;
  final bool isNullable;
  final String sqlType;
  final TypeConverter? typeConverter;
  final Embed? embedConverter;

  Field(
    this.fieldElement,
    this.name,
    this.columnName,
    this.isNullable,
    this.sqlType,
    this.typeConverter,
    this.embedConverter,
  );

  /// The database column definition.
  String getDatabaseDefinition(final bool autoGenerate) {
    if (embedConverter != null) {
      throw InvalidGenerationSourceError(
          'You ',
        todo: 'Either make to use a supported type or supply a type converter.',
        element: fieldElement,
      );
    }

    final columnSpecification = StringBuffer();

    if (autoGenerate) {
      columnSpecification.write(' PRIMARY KEY AUTOINCREMENT');
    }
    if (!isNullable) {
      columnSpecification.write(' NOT NULL');
    }

    return '`$columnName` $sqlType$columnSpecification';
  }

  Field copyWith({
    String columnNamePrefix = '',
  }) => Field(fieldElement,
    name,
    '$columnNamePrefix$columnName',
    isNullable,
    sqlType,
    typeConverter, embedConverter,
  );

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
