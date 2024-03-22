import 'dart:async';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:collection/collection.dart';
import 'package:floor_common/src/util/string_utils.dart';

import 'package:sqlparser/sqlparser.dart';

import '../util/constants.dart';

/// This class knows how to execute database queries.
class QueryAdapter {
  final DatabaseExecutor _database;
  final StreamController<String>? _changeListener;
  late final SqlEngine _sqlEngine = SqlEngine();

  QueryAdapter(
    final DatabaseExecutor database, [
    final StreamController<String>? changeListener,
  ])  : _database = database,
        _changeListener = changeListener;

  /// Executes a SQLite query that may return a single value.
  Future<T?> query<T>(
    final String sql, {
    final List<Object>? arguments,
    required final T Function(Map<String, Object?>) mapper,
  }) async {
    final rows = await _preformQuery(sql, arguments);

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
    final List<Object>? arguments,
    required final T Function(Map<String, Object?>) mapper,
  }) async {
    final rootNode = _parseRootNode(sql);

    if (rootNode is SelectStatement) {
      return _database
          .rawQuery(sql, arguments)
          .then((rows) => rows.map((row) => mapper(row)).toList());
    } else {
      throw StateError(
          'Unsupported query "$sql" for List return type. It should be SELECT, since DELETE, UPDATE, INSERT returns `int` type.');
    }
  }

  Future<void> queryNoReturn(
    final String sql, {
    final List<Object>? arguments,
  }) async {
    await _preformQuery(sql, arguments);
  }

  /// Executes a SQLite query that returns a stream of single query results
  /// or `null`.
  Stream<T?> queryStream<T>(
    final String sql, {
    final List<Object>? arguments,
    required final String queryableName,
    required final bool isView,
    required final T Function(Map<String, Object?>) mapper,
  }) {
    // ignore: close_sinks
    final changeListener = ArgumentError.checkNotNull(_changeListener);
    final controller = StreamController<T?>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await query(sql, arguments: arguments, mapper: mapper);
      controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    // listen on all updates if the stream is on a view, only listen to the
    // name of the table if the stream is on a entity.
    final subscription = changeListener.stream
        .where((updatedTable) =>
            isView || updatedTable.equals(queryableName, ignoreCase: true))
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
    final List<Object>? arguments,
    required final String queryableName,
    required final bool isView,
    required final T Function(Map<String, Object?>) mapper,
  }) {
    // ignore: close_sinks
    final changeListener = ArgumentError.checkNotNull(_changeListener);
    final controller = StreamController<List<T>>.broadcast();

    Future<void> executeQueryAndNotifyController() async {
      final result = await queryList(sql, arguments: arguments, mapper: mapper);
      controller.add(result);
    }

    controller.onListen = () async => executeQueryAndNotifyController();

    // Views listen on all events, Entities only on events that changed the same entity.
    final subscription = changeListener.stream
        .where((updatedTable) =>
            isView || updatedTable.equals(queryableName, ignoreCase: true))
        .listen(
          (_) async => executeQueryAndNotifyController(),
          onDone: () => controller.close(),
        );

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  /// Parses the SQL query to determine which method is declared and executes it.
  Future<List<Map<String, Object?>>> _preformQuery(
    String sql,
    List<Object>? arguments,
  ) async {
    List<Map<String, Object?>> result = List.empty();
    String tableName = '';
    final rootNode = _parseRootNode(sql);

    if (rootNode is SelectStatement) {
      result = await _database.rawQuery(sql, arguments);
    } else if (rootNode is InsertStatement) {
      result = await _database.rawInsert(sql, arguments).then(_mapResult);
      tableName = rootNode.table.tableName;
    } else if (rootNode is UpdateStatement) {
      result = await _database.rawUpdate(sql, arguments).then(_mapResult);
      tableName = rootNode.table.tableName;
    } else if (rootNode is DeleteStatement) {
      result = await _database.rawDelete(sql, arguments).then(_mapResult);
      tableName = rootNode.table.tableName;
    }

    _notifyIfChanged(tableName, result);

    return result;
  }

  /// Checks the query result, if it is a table change, notifies by table name.
  void _notifyIfChanged(
    String tableName,
    List<Map<String, Object?>> result,
  ) {
    final count = result.firstOrNull?[changedRowsKey];
    if (tableName.isNotEmpty && count is int && count > 0) {
      _changeListener?.add(tableName);
    }
  }

  /// Converts the modification `int` result to a query result.
  FutureOr<List<Map<String, Object?>>> _mapResult(int value) => [
        {changedRowsKey: value}
      ];

  /// Parses a root node to validate SQL
  AstNode _parseRootNode(String sql) => _sqlEngine.parse(sql).rootNode;
}
