class Index {
  final String name;
  final String tableName;
  final bool unique;
  final List<String> columnNames;

  Index(this.name, this.tableName, this.unique, this.columnNames);

  String createQuery() {
    final uniqueSql = unique ? ' UNIQUE' : '';
    final escapedColumnNames =
        columnNames.map((columnName) => '`$columnName`').join(', ');

    return 'CREATE$uniqueSql INDEX `$name`'
        ' ON `$tableName` ($escapedColumnNames)';
  }

  static const defaultPrefix = 'index_';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Index &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          tableName == other.tableName &&
          unique == other.unique &&
          columnNames == other.columnNames;

  @override
  int get hashCode =>
      name.hashCode ^
      tableName.hashCode ^
      unique.hashCode ^
      columnNames.hashCode;

  @override
  String toString() {
    return 'Index{name: $name, tableName: $tableName, unique: $unique, columnNames: $columnNames}';
  }
}
