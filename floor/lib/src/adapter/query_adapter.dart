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
    @required final T Function(Map<String, dynamic>) mapper,
  }) async {
    final rows = await _database.rawQuery(sql, arguments);

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
    @required final T Function(Map<String, dynamic>) mapper,
  }) async {
    final rows = await _database.rawQuery(sql, arguments);

    return rows.map(mapper).toList();
  }

  /// Executes a SQLite query that does not return any values.
  /// It will also trigger the [_changeListener] of affected entities if this
  /// query is expected to change something.
  Future<void> queryNoReturn(
    final String sql, {
    final List<dynamic> arguments,
    final Set<String> changedEntities,
  }) async {
    await _database.rawQuery(sql, arguments);

    if (_changeListener != null &&
        changedEntities != null &&
        changedEntities.isNotEmpty) {
      changedEntities.forEach(_changeListener.add);
    }
  }

  /// Executes a SQLite query that returns a stream of single query results.
  Stream<T> queryStream<T>(
    final String sql, {
    final List<dynamic> arguments,
    @required final Set<String> dependencies,
    @required final T Function(Map<String, dynamic>) mapper,
  }) {
    assert(_changeListener != null);

    final controller = StreamController<T>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await query(sql, arguments: arguments, mapper: mapper);
      if (result != null) controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    // listen on all updates where the updated table
    // is one of the dependencies of this query.
    final subscription = _changeListener.stream
        .where(dependencies.contains)
        .listen((_) async => executeQueryAndNotifyController(),
            onDone: () => controller.close());

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  /// Executes a SQLite query that returns a stream of multiple query results.
  Stream<List<T>> queryListStream<T>(
    final String sql, {
    final List<dynamic> arguments,
    @required final Set<String> dependencies,
    @required final T Function(Map<String, dynamic>) mapper,
  }) {
    assert(_changeListener != null);

    final controller = StreamController<List<T>>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await queryList(sql, arguments: arguments, mapper: mapper);
      controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    // listen on all updates where the updated table
    // is one of the dependencies of this query.
    final subscription = _changeListener.stream
        .where(dependencies.contains)
        .listen((_) async => executeQueryAndNotifyController(),
            onDone: () => controller.close());

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }
}
