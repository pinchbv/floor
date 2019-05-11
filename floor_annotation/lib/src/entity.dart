import 'package:floor_annotation/src/foreign_key.dart';
import 'package:floor_annotation/src/index.dart';

/// Marks a class as a database entity (table).
class Entity {
  /// The table name of the SQLite table.
  final String tableName;

  final bool readOnly;

  /// List of indices on the table.
  final List<Index> indices;

  /// List of [ForeignKey] constraints on this entity.
  final List<ForeignKey> foreignKeys;

  /// Marks a class as a database entity (table).
  const Entity({
    this.tableName,
    this.readOnly,
    this.indices = const [],
    this.foreignKeys = const [],
  });
}

/// Marks a class as a database entity (table).
const entity = Entity();
