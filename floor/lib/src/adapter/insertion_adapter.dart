import 'dart:async';

import 'package:sqflite/sqflite.dart';

class InsertionAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final Map<String, dynamic> Function(T) _valueMapper;
  final StreamController<String> _changeListener;

  InsertionAdapter(
    final DatabaseExecutor database,
    final String entityName,
    final Map<String, dynamic> Function(T) valueMapper, [
    final StreamController<String> changeListener,
  ])  : assert(database != null),
        assert(entityName != null),
        assert(entityName.isNotEmpty),
        assert(valueMapper != null),
        _database = database,
        _entityName = entityName,
        _valueMapper = valueMapper,
        _changeListener = changeListener;

  Future<void> insert(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    await _insert(item, conflictAlgorithm);
  }

  Future<void> insertList(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    if (items.isEmpty) return;
    await _insertList(items, conflictAlgorithm);
  }

  Future<int> insertAndReturnId(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) {
    return _insert(item, conflictAlgorithm);
  }

  Future<List<int>> insertListAndReturnIds(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    if (items.isEmpty) return [];
    return _insertList(items, conflictAlgorithm);
  }

  Future<int> _insert(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    final result = await _database.insert(
      _entityName,
      _valueMapper(item),
      conflictAlgorithm: conflictAlgorithm,
    );
    if (_changeListener != null && result != null) {
      _changeListener.add(_entityName);
    }
    return result;
  }

  Future<List<int>> _insertList(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    final batch = _database.batch();
    for (final item in items) {
      batch.insert(
        _entityName,
        _valueMapper(item),
        conflictAlgorithm: conflictAlgorithm,
      );
    }
    final result = (await batch.commit(noResult: false)).cast<int>();
    if (_changeListener != null && result.isNotEmpty) {
      _changeListener.add(_entityName);
    }
    return result;
  }
}
