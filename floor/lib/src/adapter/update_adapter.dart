import 'dart:async';

import 'package:sqflite/sqflite.dart';

class UpdateAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final String _primaryKeyColumnName;
  final Map<String, dynamic> Function(T) _valueMapper;
  final StreamController<String> _changeListener;

  UpdateAdapter(
    final DatabaseExecutor database,
    final String entityName,
    final String primaryKeyColumnName,
    final Map<String, dynamic> Function(T) valueMapper, [
    final StreamController<String> changeListener,
  ])  : assert(database != null),
        assert(entityName != null),
        assert(entityName.isNotEmpty),
        assert(primaryKeyColumnName != null),
        assert(primaryKeyColumnName.isNotEmpty),
        assert(valueMapper != null),
        _database = database,
        _entityName = entityName,
        _valueMapper = valueMapper,
        _primaryKeyColumnName = primaryKeyColumnName,
        _changeListener = changeListener;

  Future<void> update(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    await _update(item, conflictAlgorithm);
  }

  Future<void> updateList(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    if (items.isEmpty) return;
    await _updateList(items, conflictAlgorithm);
  }

  Future<int> updateAndReturnChangedRows(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) {
    return _update(item, conflictAlgorithm);
  }

  Future<int> updateListAndReturnChangedRows(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    if (items.isEmpty) return 0;
    return _updateList(items, conflictAlgorithm);
  }

  Future<int> _update(
    final T item,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    final values = _valueMapper(item);
    final int primaryKey = values[_primaryKeyColumnName];

    final result = await _database.update(
      _entityName,
      values,
      where: '$_primaryKeyColumnName = ?',
      whereArgs: <int>[primaryKey],
      conflictAlgorithm: conflictAlgorithm,
    );
    if (_changeListener != null && result != 0) {
      _changeListener.add(_entityName);
    }
    return result;
  }

  Future<int> _updateList(
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) async {
    final batch = _database.batch();
    for (final item in items) {
      final values = _valueMapper(item);
      final int primaryKey = values[_primaryKeyColumnName];

      batch.update(
        _entityName,
        values,
        where: '$_primaryKeyColumnName = ?',
        whereArgs: <int>[primaryKey],
        conflictAlgorithm: conflictAlgorithm,
      );
    }
    final result = (await batch.commit(noResult: false)).cast<int>();
    if (_changeListener != null && result.isNotEmpty) {
      _changeListener.add(_entityName);
    }
    return result.isNotEmpty
        ? result.reduce((sum, element) => sum + element)
        : 0;
  }
}
