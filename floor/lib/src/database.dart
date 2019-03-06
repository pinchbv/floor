import 'dart:async';

import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  @protected
  final changeListener = StreamController<String>.broadcast();

  /// Use this whenever you want need direct access to the sqflite database.
  sqflite.DatabaseExecutor database;

  /// Opens the database to be able to query it.
  Future<sqflite.Database> open(List<Migration> migrations);

  /// Closes the database.
  Future<void> close() async {
    await changeListener.close();

    final immutableDatabase = database;
    if (immutableDatabase is sqflite.Database &&
        (immutableDatabase?.isOpen ?? false)) {
      await immutableDatabase.close();
    }
  }
}
