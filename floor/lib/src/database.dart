import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  /// Use this whenever you want need direct access to the sqflite database.
  sqflite.DatabaseExecutor database;

  // TODO remove this
  /// Opens the database to be able to query it.
  Future<sqflite.Database> open(List<Migration> migrations);

  /// Closes the database.
  Future<void> close() async {
    final immutableDatabase = database;
    if (immutableDatabase is sqflite.Database &&
        (immutableDatabase?.isOpen ?? false)) {
      await immutableDatabase.close();
    }
  }

  /// Runs the given [migrations] for migrating the database schema and data.
  @protected
  void runMigrations(
    final sqflite.Database migrationDatabase,
    final int startVersion,
    final int endVersion,
    final List<Migration> migrations,
  ) {
    final relevantMigrations = migrations
        .where((migration) => migration.startVersion >= startVersion)
        .toList()
          ..sort((first, second) =>
              first.startVersion.compareTo(second.startVersion));

    if (relevantMigrations.isEmpty ||
        relevantMigrations.last.endVersion != endVersion) {
      throw StateError(
        'There is no migration supplied to update the database to the current version.'
            ' Aborting the migration.',
      );
    }

    for (final migration in relevantMigrations) {
      migration.migrate(migrationDatabase);
    }
  }
}
