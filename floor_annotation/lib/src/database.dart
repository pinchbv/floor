/// Marks a class as a FloorDatabase.
class Database {
  /// The database version.
  final int version;

  /// The database password
  final String? password;

  /// The entities the database manages.
  final List<Type> entities;

  /// The views the database manages.
  final List<Type> views;

  /// Marks a class as a FloorDatabase.
  const Database({
    required this.version,
    this.password,
    required this.entities,
    this.views = const [],
  });
}
