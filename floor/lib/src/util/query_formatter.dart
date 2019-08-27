class QueryFormatter {

  static String getGroupPrimaryKeyQuery(
    List<String> groupPrimaryKey,
  ) =>
      groupPrimaryKey.map((columnName) => '$columnName = ?').join(' AND ');

  static List<dynamic> getGroupPrimaryKeyArgs(
    Map<String, dynamic> values,
    List<String> groupPrimaryKey,
  ) =>
      groupPrimaryKey.map<dynamic>((key) => values[key]).toList();
}
