import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  /// [StreamController] that is responsible for notifying listeners about changes
  /// in specific tables. It acts as an event bus.
  @protected
  late StreamController<String> changeListener;

  /// Use this whenever you need direct access to the sqflite database.
  late sqflite.DatabaseExecutor database;

  /// Closes the database.
  Future<void> close() async {
    await changeListener.close();

    final immutableDatabase = database;
    if (immutableDatabase is sqflite.Database && immutableDatabase.isOpen) {
      await immutableDatabase.close();
    }
  }
}
