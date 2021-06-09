import 'dart:async';

import 'package:sqflite/sqflite.dart';

/// Callback class that can be attached to the Floor builder.
class Callback {
  /// Fired when the [database] has been just created with [version].
  /// All actions are run within a single transaction.
  final FutureOr<void> Function(
    Database database,
    int version,
  )? onCreate;

  /// Fired when the [database] has successfully been opened.
  final FutureOr<void> Function(Database database)? onOpen;

  /// Fired when the [database] will be configured (will run before migrations, onCreate and onUpgrade hooks).
  final FutureOr<void> Function(Database database)? onConfigure;

  /// Fired when the [database] has finished upgrading from [startVersion] to [endVersion].
  /// All actions are run within a single transaction.
  final FutureOr<void> Function(
    Database database,
    int startVersion,
    int endVersion,
  )? onUpgrade;

  /// Fired when the [database] failed upgrading caused by [exception] from
  /// [startVersion] to [endVersion], before dropping all existing data and re-creating the schema.
  final FutureOr<void> Function(
    Database database,
    int startVersion,
    int endVersion,
    Exception exception,
  )? onDestructiveUpgrade;

  /// Fired when the [database] is downgrading from [startVersion] to
  /// [endVersion], before dropping all existing data and re-creating the schema.
  final FutureOr<void> Function(
    Database database,
    int startVersion,
    int endVersion,
  )? onDestructiveDowngrade;

  /// Constructor.
  const Callback({
    this.onConfigure,
    this.onCreate,
    this.onOpen,
    this.onUpgrade,
    this.onDestructiveUpgrade,
    this.onDestructiveDowngrade,
  });
}
