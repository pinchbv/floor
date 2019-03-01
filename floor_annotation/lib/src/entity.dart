import 'package:floor_annotation/src/foreign_key.dart';

/// Marks a class as a database entity (table).
class Entity {
  /// The table name of the SQLite table.
  final String tableName;

  /// List of [ForeignKey] constraints on this entity.
  final List<ForeignKey> foreignKeys;

  const Entity({this.tableName, this.foreignKeys});
}

/// Marks a class as a database entity (table).
const entity = Entity();
