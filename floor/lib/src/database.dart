import 'package:sqflite/sqflite.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  /// Use this for direct access to the sqflite database.
  sqflite.DatabaseExecutor database;

  // TODO remove this
  /// Opens the database to be able to query it.
  Future<sqflite.Database> open();

  /// Closes the database.
  Future<void> close() async {
    final immutableDatabase = database;
    if (immutableDatabase is sqflite.Database &&
        (immutableDatabase?.isOpen ?? false)) {
      await immutableDatabase.close();
    }
  }
}
