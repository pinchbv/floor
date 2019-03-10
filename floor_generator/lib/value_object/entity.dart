import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';

class Entity {
  final ClassElement classElement;
  final String name;
  final List<Field> fields;
  final PrimaryKey primaryKey;
  final List<ForeignKey> foreignKeys;
  final List<Index> indices;
  final String constructor;

  Entity(
    this.classElement,
    this.name,
    this.fields,
    this.primaryKey,
    this.foreignKeys,
    this.indices,
    this.constructor,
  );

  @nonNull
  String getCreateTableStatement() {
    final databaseDefinition = fields
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
    final columnNames = fields.map((field) => field.columnName).toList();
    final constructorParameters = classElement.constructors.first.parameters;

    final keyValueList = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final valueMapping = _getValueMapping(constructorParameters[i]);
      keyValueList.add("'${columnNames[i]}': $valueMapping");
    }

    return '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  @nonNull
  String _getValueMapping(final ParameterElement parameter) {
    final parameterName = parameter.displayName;
    return isBool(parameter.type)
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
          fields == other.fields &&
          primaryKey == other.primaryKey &&
          foreignKeys == other.foreignKeys &&
          indices == other.indices &&
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
