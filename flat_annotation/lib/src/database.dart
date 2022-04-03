/// Marks a class as a FlatDatabase.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages.
  final List<Type> entities;

  /// The views the database manages.
  final List<Type> views;

  /// Marks a class as a FlatDatabase.
  const Database({
    required this.version,
    required this.entities,
    this.views = const [],
  });
}
