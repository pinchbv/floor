class SQLiteQuery {
  SQLiteQuery(this.query, {this.arguments});

  final String query;

  final List<Object>? arguments;
}
