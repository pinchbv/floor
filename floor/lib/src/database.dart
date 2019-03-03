import 'package:floor/floor.dart';
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
}
