/// Utility functions for primary key actions
class PrimaryKeyHelper {
  /// Creates the WHERE clause in order to select the rows to be changed
  static String getWhereClause(final List<String> groupPrimaryKey) {
    return groupPrimaryKey.map((columnName) => '$columnName = ?').join(' AND ');
  }

  /// Obtains the primary key values
  static List<dynamic> getPrimaryKeyValues(
      final List<String> primaryKeys,
      final Map<String, dynamic> values,
      ) {
    return primaryKeys.map<dynamic>((key) => values[key]).toList();
  }
}
