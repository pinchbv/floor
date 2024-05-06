import 'package:sqflite_common/sqlite_api.dart' as sqflite;

/// Base class for a database migration.
///
/// Each migration can move between 2 versions that are defined by
/// [startVersion] and [endVersion].
class Migration {
  /// The start version of the database.
  final int startVersion;

  /// The start version of the database.
  final int endVersion;

  /// Function that performs the migration.
  final Future<void> Function(sqflite.Database database) migrate;

  /// Creates a new migration between [startVersion] and [endVersion].
  /// [migrate] will be called by the database and performs the actual
  /// migration.
  Migration(this.startVersion, this.endVersion, this.migrate)
      : assert(startVersion > 0),
        assert(startVersion < endVersion);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Migration &&
          runtimeType == other.runtimeType &&
          startVersion == other.startVersion &&
          endVersion == other.endVersion &&
          migrate == other.migrate;

  @override
  int get hashCode =>
      startVersion.hashCode ^ endVersion.hashCode ^ migrate.hashCode;

  @override
  String toString() {
    return 'Migration{startVersion: $startVersion, endVersion: $endVersion, migrate: $migrate}';
  }
}
