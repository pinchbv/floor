import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'migration.dart';

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  /// [StreamController] that is responsible for notifying listeners about changes
  /// in specific tables. It acts as an event bus.
  @protected
  StreamController<String> changeListener;

  /// Use this whenever you need direct access to the sqflite database.
  sqflite.DatabaseExecutor database;

  // Opens the database and optionally performs database migrations.
  Future<sqflite.Database> open(String name, List<Migration> migrations,
      [Callback callback]);

  /// Closes the database.
  Future<void> close() async {
    await changeListener?.close();

    final immutableDatabase = database;
    if (immutableDatabase is sqflite.Database &&
        (immutableDatabase?.isOpen ?? false)) {
      await immutableDatabase.close();
    }
  }
}
