import 'package:meta/meta.dart';

/// Marks a class as a FloorDatabase.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages-
  final List<Type> entities;

  /// Marks a class as a FloorDatabase.
  const Database({@required this.version, @required this.entities});
}
