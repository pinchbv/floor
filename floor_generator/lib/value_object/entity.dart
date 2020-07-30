import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/embedded.dart';
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
    ClassElement classElement,
    String name,
    List<Field> fields,
    List<Embedded> embeddeds,
    this.primaryKey,
    this.foreignKeys,
    this.indices,
    String constructor,
  ) : super(classElement, name, fields, embeddeds, constructor);

  @nonNull
  String getCreateTableStatement() {
    final databaseDefinition = fields.map((field) {
      final autoIncrement =
          primaryKey.fields.contains(field) && primaryKey.autoGenerateId;
      return field.getDatabaseDefinition(autoIncrement);
    }).toList();

    final embeddedDefinitions = embeddeds

        // dig into children to expand fields
        .expand((embedded) {
          final fields = <Field>[];

          void dig(final Embedded child) {
            fields.addAll(child.fields);
            child.children.forEach(dig);
          }

          dig(embedded);

          return fields;
        })
        .map((field) => field.getDatabaseDefinition(false))
        .toList();
    databaseDefinition.addAll(embeddedDefinitions);

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
    final keyValueList = <String>[];

    final fieldKeyValue = fields.map((field) {
      final columnName = field.columnName;
      final attributeValue = _getAttributeValue(field);
      return "'$columnName': item.$attributeValue";
    }).toList();
    keyValueList.addAll(fieldKeyValue);

    final embeddedKeyValue = embeddeds.expand((embedded) {
      final keyValue = <String>[];
      final className = <String>[];

      void dig(final Embedded child) {
        className.add(child.fieldElement.displayName);
        for (final field in child.fields) {
          final columnName = field.columnName;
          final attributeValue =
              [...className, _getAttributeValue(field)].join('?.');
          keyValue.add("'$columnName': item.$attributeValue");
        }

        child.children.forEach(dig);
      }

      dig(embedded);

      return keyValue;
    }).toList();
    keyValueList.addAll(embeddedKeyValue);

    return '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  @nonNull
  String _getAttributeValue(final Field field) {
    final parameterName = field.fieldElement.displayName;
    if (field.fieldElement.type.isDartCoreBool) {
      return '$parameterName?.toInt()';
    } else {
      return '$parameterName';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          const ListEquality<Embedded>().equals(embeddeds, other.embeddeds) &&
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
      embeddeds.hashCode ^
      primaryKey.hashCode ^
      foreignKeys.hashCode ^
      indices.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'Entity{classElement: $classElement, name: $name, fields: $fields, embeddeds: $embeddeds, primaryKey: $primaryKey, foreignKeys: $foreignKeys, indices: $indices, constructor: $constructor}';
  }
}
