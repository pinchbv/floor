import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqflite;

/// Callback class that can be attached to the Floor builder.
class Callback {
  /// Fired when the [database] has been just created with [version].
  final FutureOr<void> Function(
    sqflite.Database database,
    int version,
  ) onCreate;

  /// Fired when the [database] has successfully been opened.
  final FutureOr<void> Function(sqflite.Database database) onOpen;

  /// Fired when the [database] has finished upgrading from [startVersion] to [endVersion].
  final FutureOr<void> Function(
    sqflite.Database database,
    int startVersion,
    int endVersion,
  ) onUpgrade;

  /// Constructor.
  const Callback({this.onCreate, this.onOpen, this.onUpgrade});
}
