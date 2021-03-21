import 'dart:async';

import 'package:floor/src/extension/on_conflict_strategy_extensions.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:sqflite/sqlite_api.dart';

class InsertionAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final Map<String, Object?> Function(T) _valueMapper;
  final StreamController<String>? _changeListener;
  final void Function(int id, T entity)? _inserted;

  InsertionAdapter(
    final DatabaseExecutor database,
    final String entityName,
    final Map<String, Object?> Function(T) valueMapper,
      {
        final void Function(int id, T entity)? inserted,
        final StreamController<String>? changeListener,
      })  : assert(entityName.isNotEmpty),
        _database = database,
        _entityName = entityName,
        _valueMapper = valueMapper,
        _changeListener = changeListener,
        _inserted = inserted;

  Future<void> insert(
    final T item,
    final OnConflictStrategy onConflictStrategy,
  ) async {
    await _insert(item, onConflictStrategy);
  }

  Future<void> insertList(
    final List<T> items,
    final OnConflictStrategy onConflictStrategy,
  ) async {
    if (items.isEmpty) return;
    final batch = _database.batch();
    for (final item in items) {
      batch.insert(
        _entityName,
        _valueMapper(item),
        conflictAlgorithm: onConflictStrategy.asSqfliteConflictAlgorithm(),
      );
    }
    final result = (await batch.commit(noResult: false)).cast<int>();
    if (_inserted != null) {
      for (var i = 0; i < result.length; i++) {
        _inserted!(result[i], items[i]);
      }
    }
    _changeListener?.add(_entityName);
  }

  Future<int> insertAndReturnId(
    final T item,
    final OnConflictStrategy onConflictStrategy,
  ) {
    return _insert(item, onConflictStrategy);
  }

  Future<List<int>> insertListAndReturnIds(
    final List<T> items,
    final OnConflictStrategy onConflictStrategy,
  ) async {
    if (items.isEmpty) return [];
    final batch = _database.batch();
    for (final item in items) {
      batch.insert(
        _entityName,
        _valueMapper(item),
        conflictAlgorithm: onConflictStrategy.asSqfliteConflictAlgorithm(),
      );
    }
    final result = (await batch.commit(noResult: false)).cast<int>();
    if (result.isNotEmpty) {
      _changeListener?.add(_entityName);
      if (_inserted != null) {
        for (var i = 0; i < result.length; i++) {
          _inserted!(result[i], items[i]);
        }
      }
    }
    return result;
  }

  Future<int> _insert(
    final T item,
    final OnConflictStrategy onConflictStrategy,
  ) async {
    final result = await _database.insert(
      _entityName,
      _valueMapper(item),
      conflictAlgorithm: onConflictStrategy.asSqfliteConflictAlgorithm(),
    );
    if (result != 0) {
      if (_inserted != null) {
        _inserted!(result, item);
      }
      _changeListener?.add(_entityName);
    }
    return result;
  }
}
