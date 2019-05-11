import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';

class Entity {
  final ClassElement classElement;
  final String name;
  final bool readOnly;
  final List<Field> fields;
  final PrimaryKey primaryKey;
  final List<ForeignKey> foreignKeys;
  final List<Index> indices;
  final String constructor;

  Entity(
    this.classElement,
    this.name,
    this.readOnly,
    this.fields,
    this.primaryKey,
    this.foreignKeys,
    this.indices,
    this.constructor,
  );

  @nonNull
  String getCreateTableStatement() {
    final databaseDefinition = fields
        .where((f) => !f.readOnly)
        .map((field) => field.getDatabaseDefinition(
            field == primaryKey.field && primaryKey.autoGenerateId))
        .toList();

    final foreignKeyDefinitions =
        foreignKeys.map((foreignKey) => foreignKey.getDefinition()).toList();

    databaseDefinition.addAll(foreignKeyDefinitions);

    return 'CREATE TABLE IF NOT EXISTS `$name` (${databaseDefinition.join(', ')})';
  }

  @nonNull
  String getValueMapping() {
    final keyValueList = fields.where((f) => !f.readOnly).map((field) {
      final columnName = field.columnName;
      final attributeValue = _getAttributeValue(field.fieldElement);
      return "'$columnName': $attributeValue";
    }).toList();

    return '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  @nonNull
  String _getAttributeValue(final FieldElement fieldElement) {
    final parameterName = fieldElement.displayName;
    return isBool(fieldElement.type)
        ? 'item.$parameterName ? 1 : 0'
        : 'item.$parameterName';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          primaryKey == other.primaryKey &&
          const ListEquality<ForeignKey>()
              .equals(foreignKeys, other.foreignKeys) &&
          const ListEquality<Index>().equals(indices, other.indices) &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      fields.hashCode ^
      primaryKey.hashCode ^
      foreignKeys.hashCode ^
      indices.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'Entity{classElement: $classElement, name: $name, fields: $fields, primaryKey: $primaryKey, foreignKeys: $foreignKeys, indices: $indices, constructor: $constructor}';
  }
}
