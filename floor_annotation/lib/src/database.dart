/// Marks a class as a FloorDatabase.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages.
  final List<Type> entities;

  /// The views the database manages.
  final List<Type> views;

  // Re-create the database if migration fails or is missing.
  final bool fallbackToDestructiveMigration;

  /// Marks a class as a FloorDatabase.
  const Database({
    required this.version,
    required this.entities,
    this.fallbackToDestructiveMigration = false,
    this.views = const [],
  });
}
