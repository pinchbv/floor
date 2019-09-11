import 'package:meta/meta.dart';

/// Marks a class as a FloorDatabase.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages.
  final List<Type> entities;

  /// Whether the open() method should be annotated with @override.
  final bool overrideOpen;

  /// Marks a class as a FloorDatabase.
  const Database({
    @required this.version,
    @required this.entities,
    @required this.overrideOpen,
  });
}
