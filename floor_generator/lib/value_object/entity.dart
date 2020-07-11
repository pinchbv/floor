import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:floor_generator/value_object/queryable.dart';

class Entity extends Queryable {
  final PrimaryKey primaryKey;
  final List<ForeignKey> foreignKeys;
  final List<Index> indices;

  Entity(
    String className,
    String name,
    List<Field> fields,
    this.primaryKey,
    this.foreignKeys,
    this.indices,
    String constructor,
  ) : super(className, name, fields, constructor);

  @nonNull
  String getCreateTableStatement() {
    final databaseDefinition = fields.map((field) {
      final autoIncrement =
          primaryKey.fields.contains(field) && primaryKey.autoGenerateId;
      return field.getDatabaseDefinition(autoIncrement);
    }).toList();

    final foreignKeyDefinitions =
        foreignKeys.map((foreignKey) => foreignKey.getDefinition()).toList();
    databaseDefinition.addAll(foreignKeyDefinitions);

    final primaryKeyDefinition = _createPrimaryKeyDefinition();
    if (primaryKeyDefinition != null) {
      databaseDefinition.add(primaryKeyDefinition);
    }

    return 'CREATE TABLE IF NOT EXISTS `$name` (${databaseDefinition.join(', ')})';
  }

  @nullable
  String _createPrimaryKeyDefinition() {
    if (primaryKey.autoGenerateId) {
      return null;
    } else {
      final columns =
          primaryKey.fields.map((field) => '`${field.columnName}`').join(', ');
      return 'PRIMARY KEY ($columns)';
    }
  }

  @nonNull
  String getValueMapping() {
    final keyValueList = fields.map((field) {
      final columnName = field.columnName;
      final attributeValue = _getAttributeValue(field);
      return "'$columnName': $attributeValue";
    }).toList();

    return '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  @nonNull
  String _getAttributeValue(final Field field) {
    final parameterName = field.fieldElement.displayName;
    if (field.fieldElement.type.isDartCoreBool) {
      if (field.isNullable) {
        return 'item.$parameterName == null ? null : (item.$parameterName ? 1 : 0)';
      } else {
        return 'item.$parameterName ? 1 : 0';
      }
    } else {
      return 'item.$parameterName';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          name == other.name &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          primaryKey == other.primaryKey &&
          const ListEquality<ForeignKey>()
              .equals(foreignKeys, other.foreignKeys) &&
          const ListEquality<Index>().equals(indices, other.indices) &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      className.hashCode ^
      name.hashCode ^
      fields.hashCode ^
      primaryKey.hashCode ^
      foreignKeys.hashCode ^
      indices.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'Entity{className: $className, name: $name, fields: $fields, primaryKey: $primaryKey, foreignKeys: $foreignKeys, indices: $indices, constructor: $constructor}';
  }
}
