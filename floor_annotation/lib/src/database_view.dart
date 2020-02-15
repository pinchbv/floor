/// Marks a class as a database view (a fixed select statement).
class DatabaseView {
  /// The table name of the SQLite view.
  final String viewName;

  /// The SELECT query on which the view is based on.
  final String query;

  /// Marks a class as a database entity (table).
  const DatabaseView(
    this.query, {
    this.viewName,
  });
}
