/// Marks a class as a FloorDatabase.
class Database {
  const Database();
}

const database = Database();

/// Marks a class as a database entity (table).
class Entity {
  /// The table name of the SQLite table.
  final String tableName;

  const Entity({this.tableName});
}

const entity = Entity();

/// Allows customization of the column associated with this field.
class ColumnInfo {
  /// The custom name of the column.
  final String name;

  // Does it make sense to have this field?
  // It's very easy to still assign `null` to the field without recognising.
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

const primaryKey = PrimaryKey();

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
