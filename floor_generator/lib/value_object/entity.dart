import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:floor_generator/value_object/queryable.dart';

import 'fts.dart';

class Entity extends Queryable {
  final PrimaryKey primaryKey;
  final List<ForeignKey> foreignKeys;
  final List<Index> indices;
  final bool withoutRowid;
  final String valueMappingForInsert;
  final String valueMappingForUpdate;
  final String valueMappingForDelete;
  final Fts? fts;
  final String saveSub;

  Entity(
    ClassElement classElement,
    String name,
    List<Field> fieldsAll,
    List<Field> fieldsDataBaseSchema,
    List<Field> fieldsQuery,
    this.primaryKey,
    this.foreignKeys,
    this.indices,
    this.withoutRowid,
    String constructor,
      this.valueMappingForInsert,
      this.valueMappingForUpdate,
      this.valueMappingForDelete,
      this.fts,
      [this.saveSub = '']
  ) : super(name: name, classElement: classElement, constructor: constructor, fieldsAll: fieldsAll, fieldsDataBaseSchema: fieldsDataBaseSchema, fieldsQuery: fieldsQuery);

  String getCreateTableStatement() {
    final databaseDefinition = fieldsDataBaseSchema.map((field) {
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

    final withoutRowidClause = withoutRowid ? ' WITHOUT ROWID' : '';

    if (fts == null) {
      return 'CREATE TABLE IF NOT EXISTS `$name` (${databaseDefinition.join(', ')})$withoutRowidClause';
    } else {
      if (fts!.tableCreateOption().isNotEmpty) {
        databaseDefinition.add('${fts!.tableCreateOption()}');
      }
      return 'CREATE VIRTUAL TABLE IF NOT EXISTS `$name` ${fts!.usingOption}(${databaseDefinition.join(', ')})';
    }
  }

  String? _createPrimaryKeyDefinition() {
    if (primaryKey.autoGenerateId) {
      return null;
    } else {
      final columns =
          primaryKey.fields.map((field) => '`${field.columnName}`').join(', ');
      return 'PRIMARY KEY ($columns)';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          fieldsDataBaseSchema.equals(other.fieldsDataBaseSchema) &&
          fieldsQuery.equals(other.fieldsQuery) &&
          fieldsAll.equals(other.fieldsAll) &&
          primaryKey == other.primaryKey &&
          foreignKeys.equals(other.foreignKeys) &&
          indices.equals(other.indices) &&
          withoutRowid == other.withoutRowid &&
          constructor == other.constructor &&
          valueMappingForDelete == other.valueMappingForDelete &&
          valueMappingForInsert == other.valueMappingForInsert &&
          valueMappingForUpdate == other.valueMappingForUpdate;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      fieldsDataBaseSchema.hashCode ^
      fieldsQuery.hashCode ^
      fieldsAll.hashCode ^
      primaryKey.hashCode ^
      foreignKeys.hashCode ^
      indices.hashCode ^
      constructor.hashCode ^
      withoutRowid.hashCode ^
      fts.hashCode ^
      valueMappingForDelete.hashCode ^
      valueMappingForInsert.hashCode ^
      valueMappingForUpdate.hashCode ;

  @override
  String toString() {
    return 'Entity{classElement: $classElement, name: $name, fieldsDataBaseSchema: $fieldsDataBaseSchema, fieldsQuery: $fieldsQuery, fieldsAll: $fieldsAll, primaryKey: $primaryKey, foreignKeys: $foreignKeys, indices: $indices, constructor: $constructor, withoutRowid: $withoutRowid, valueMappingForUpdate: $valueMappingForUpdate, valueMappingForInsert: $valueMappingForInsert, valueMappingForDelete: $valueMappingForDelete, fts: $fts}';
  }
}
