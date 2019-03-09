import 'dart:async';

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

  Future<T> query<T>(
    final String sql,
    final T Function(Map<String, dynamic>) mapper,
  ) async {
    final rows = await _database.rawQuery(sql);

    if (rows.isEmpty) {
      return null;
    } else if (rows.length > 1) {
      throw StateError("Query returned more than one row for '$sql'");
    }

    return mapper(rows.first);
  }

  Future<List<T>> queryList<T>(
    final String sql,
    final T Function(Map<String, dynamic>) mapper,
  ) async {
    final rows = await _database.rawQuery(sql);
    return rows.map((row) => mapper(row)).toList();
  }

  Future<void> queryNoReturn(final String sql) async {
    // TODO differentiate between different query kinds (select, update, delete, insert)
    //  this enables to notify the observers
    //  also requires extracting the table name :(
    await _database.rawQuery(sql);
  }

  Stream<T> queryStream<T>(
    final String sql,
    final String entityName,
    final T Function(Map<String, dynamic>) mapper,
  ) {
    assert(_changeListener != null);

    final controller = StreamController<T>();

    () async {
      final result = await query(sql, mapper);
      if (result != null) {
        controller.add(result);
      }
    }();

    final subscription = _changeListener.stream
        .where((listener) => listener == entityName)
        .listen((listener) async {
      final result = await query(sql, mapper);
      if (result != null) {
        controller.add(result);
      }
    }, onDone: () {
      controller.close();
    });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  Stream<List<T>> queryListStream<T>(
    final String sql,
    final String entityName,
    final T Function(Map<String, dynamic>) mapper,
  ) {
    assert(_changeListener != null);

    final controller = StreamController<List<T>>();

    () async {
      final result = await queryList(sql, mapper);
      controller.add(result);
    }();

    final subscription = _changeListener.stream
        .where((listener) => listener == entityName)
        .listen((listener) async {
      final result = await queryList(sql, mapper);
      controller.add(result);
    }, onDone: () {
      controller.close();
    });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}
