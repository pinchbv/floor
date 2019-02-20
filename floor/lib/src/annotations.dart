import 'package:meta/meta.dart';

/// Marks a class as a FloorDatabase.
class Database {
  /// Marks a class as a FloorDatabase.
  const Database();
}

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

/// Allows customization of the column associated with this field.
class ColumnInfo {
  /// The custom name of the column.
  final String name;

  /// Defines if the associated column is allowed to contain 'null'.
  final bool nullable;

  const ColumnInfo({this.name, this.nullable = true});
}

/// Marks a field in an [Entity] as the primary key.
class PrimaryKey {
  /// Let SQLite auto generate the unique id.
  final bool autoGenerate;

  /// Defaults [autoGenerate] to false.
  const PrimaryKey({this.autoGenerate = false});
}

/// Declares a foreign key on another [Entity].
class ForeignKey {
  /// The list of column names in the current [Entity].
  final List<String> childColumns;

  /// The list of column names in the parent [Entity].
  final List<String> parentColumns;

  /// The parent entity to reference.
  final Type entity;

  /// [ForeignKeyAction]
  final int onUpdate;

  /// [ForeignKeyAction]
  final int onDelete;

  /// Declares a foreign key on another [Entity].
  const ForeignKey({
    @required this.childColumns,
    @required this.parentColumns,
    @required this.entity,
    this.onUpdate,
    this.onDelete,
  });
}

/// Constants definition for values that can be used in
/// [ForeignKey.onDelete] and [ForeignKey.onUpdate]
abstract class ForeignKeyAction {
  /// Possible value for [ForeignKey.onDelete] or [ForeignKey.onUpdate].
  ///
  /// When a parent key is modified or deleted from the database, no special
  /// action is taken. This means that SQLite will not make any effort to fix
  /// the constraint failure, instead, reject the change.
  static const NO_ACTION = 1;

  /// Possible value for [ForeignKey.onDelete] or [ForeignKey.onUpdate].
  ///
  /// The RESTRICT action means that the application is prohibited from deleting
  /// (for [ForeignKey.onDelete]) or modifying (for [ForeignKey.onUpdate]) a
  /// parent key when there exists one or more child keys mapped to it. The
  /// difference between the effect of a RESTRICT action and normal foreign key
  /// constraint enforcement is that the RESTRICT action processing happens as
  /// soon as the field is updated - not at the end of the current statement as
  /// it would with an immediate constraint, or at the end of the current
  /// transaction as it would with a deferred() constraint.
  ///
  /// Even if the foreign key constraint it is attached to is deferred(),
  /// configuring a RESTRICT action causes SQLite to return an error immediately
  /// if a parent key with dependent child keys is deleted or modified.
  static const RESTRICT = 2;

  /// Possible value for [ForeignKey.onDelete] or [ForeignKey.onUpdate].
  ///
  /// If the configured action is 'SET NULL', then when a parent key is deleted
  /// (for [ForeignKey.onDelete]) or modified (for [ForeignKey.onUpdate]), the
  /// child key columns of all rows in the child table that mapped to the parent
  /// key are set to contain NULL values.
  static const SET_NULL = 3;

  /// Possible value for [ForeignKey.onDelete] or [ForeignKey.onUpdate].
  ///
  /// The 'SET DEFAULT' actions are similar to SET_NULL, except that each of the
  /// child key columns is set to contain the columns default value instead of
  /// NULL.
  static const SET_DEFAULT = 4;

  /// Possible value for [ForeignKey.onDelete] or [ForeignKey.onUpdate].
  ///
  /// A 'CASCADE' action propagates the delete or update operation on the parent
  /// key to each dependent child key. For [ForeignKey.onDelete] action, this
  /// means that each row in the child entity that was associated with the
  /// deleted parent row is also deleted. For an [ForeignKey.onUpdate] action,
  /// it means that the values stored in each dependent child key are modified
  /// to match the new parent key values.
  static const CASCADE = 5;
}

/// Marks a method as a query method.
class Query {
  /// The SQLite query.
  final String value;

  const Query(this.value);
}

/// Marks a method as an insert method.
class Insert {
  const Insert();
}

/// Marks a method as an insert method.
const insert = Insert();

/// Marks a method as an update method.
class Update {
  const Update();
}

/// Marks a method as an update method.
const update = Update();

/// Marks a method as a delete method.
class Delete {
  const Delete();
}

/// Marks a method as a delete method.
const delete = Delete();

/// Marks a method as a transaction method.
class _Transaction {
  const _Transaction();
}

/// Marks a method as a transaction method.
const transaction = _Transaction();
