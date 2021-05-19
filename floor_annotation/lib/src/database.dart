/// Marks a class as a FloorDatabase.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages.
  final List<Type> entities;

  /// The embeds the database manages.
  final List<Type> embeds;

  /// The views the database manages.
  final List<Type> views;

  /// Marks a class as a FloorDatabase.
  const Database({
    required this.version,
    required this.entities,
    this.embeds = const [],
    this.views = const [],
  });
}
