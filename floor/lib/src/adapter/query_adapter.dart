import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

/// This class knows how to execute database queries.
class QueryAdapter {
  final DatabaseExecutor _database;
  final StreamController<String> _changeListener;

  QueryAdapter(
    final DatabaseExecutor database, [
    final StreamController<String> changeListener,
  ])  : assert(database != null),
        _database = database,
        _changeListener = changeListener;

  /// Executes a SQLite query that may return a single value.
  Future<T> query<T>(
    final String sql, {
    final List<dynamic> arguments,
    final bool isRaw = false,
    @required final T Function(Map<String, dynamic>) mapper,
  }) async {
    final rows = await (isRaw
        ? _database.rawQuery(sql.replaceAll('?', arguments[0]))
        : _database.rawQuery(sql, arguments));

    if (rows.isEmpty) {
      return null;
    } else if (rows.length > 1) {
      throw StateError("Query returned more than one row for '$sql'");
    }

    return mapper(rows.first);
  }

  /// Executes a SQLite query that may return multiple values.
  Future<List<T>> queryList<T>(
    final String sql, {
    final List<dynamic> arguments,
    final bool isRaw = false,
    @required final T Function(Map<String, dynamic>) mapper,
  }) async {
    final rows = await (isRaw
        ? _database.rawQuery(sql.replaceAll('?', arguments[0]))
        : _database.rawQuery(sql, arguments));
    return rows.map((row) => mapper(row)).toList();
  }

  Future<void> queryNoReturn(
    final String sql, {
    final List<dynamic> arguments,
    final bool isRaw = false,
  }) async {
    // TODO differentiate between different query kinds (select, update, delete, insert)
    //  this enables to notify the observers
    //  also requires extracting the table name :(
    await (isRaw
        ? _database.rawQuery(sql.replaceAll('?', arguments[0]))
        : _database.rawQuery(sql, arguments));
  }

  /// Executes a SQLite query that returns a stream of single query results.
  Stream<T> queryStream<T>(
    final String sql, {
    final List<dynamic> arguments,
    @required final String tableName,
    @required final T Function(Map<String, dynamic>) mapper,
  }) {
    assert(_changeListener != null);

    final controller = StreamController<T>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await query(sql, arguments: arguments, mapper: mapper);
      if (result != null) controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    final subscription = _changeListener.stream
        .where((updatedTable) => updatedTable == tableName)
        .listen(
          (_) async => executeQueryAndNotifyController(),
          onDone: () => controller.close(),
        );

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  /// Executes a SQLite query that returns a stream of multiple query results.
  Stream<List<T>> queryListStream<T>(
    final String sql, {
    final List<dynamic> arguments,
    @required final String tableName,
    @required final T Function(Map<String, dynamic>) mapper,
  }) {
    assert(_changeListener != null);

    final controller = StreamController<List<T>>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await queryList(sql, arguments: arguments, mapper: mapper);
      controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    final subscription = _changeListener.stream
        .where((updatedTable) => updatedTable == tableName)
        .listen(
          (_) async => executeQueryAndNotifyController(),
          onDone: () => controller.close(),
        );

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }
}
