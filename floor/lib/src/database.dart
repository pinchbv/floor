import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Extend this class to enable database functionality.
abstract class FloorDatabase {
  @protected
  final changeListener = StreamController<String>.broadcast();

  /// Use this whenever you need direct access to the sqflite database.
  sqflite.DatabaseExecutor database;

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
