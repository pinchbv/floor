import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  /// [StreamController] that is responsible for notifying listeners about changes
  /// in specific tables. It acts as an event bus.
  @protected
  late final StreamController<String> changeListener;

  /// Use this whenever you need direct access to the sqflite database.
  late final sqflite.DatabaseExecutor database;

  /// Closes the database.
  Future<void> close() async {
    await changeListener.close();

    final database = this.database;
    if (database is sqflite.Database && database.isOpen) {
      await database.close();
    }
  }
}
