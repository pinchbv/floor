class Database {
  const Database();
}

const database = Database();

class Entity {
  final String tableName;

  const Entity({this.tableName});
}

const entity = Entity();

class ColumnInfo {
  final String name;
  // Does it make sense to have this field?
  // It's very easy to still assign `null` to the field without recognising.
  final bool nullable;

  const ColumnInfo({this.name, this.nullable = true});
}

class PrimaryKey {
  final bool autoGenerate;

  const PrimaryKey({this.autoGenerate = true});
}

const primaryKey = PrimaryKey();
