/// Represents a table column.
class Column {
  final String name;
  final String type;
  final bool isPrimaryKey;
  final bool autoGenerate;

  const Column(this.name, this.type, this.isPrimaryKey, this.autoGenerate);
}
