import 'dart:async';

import 'package:sqflite/sqflite.dart';

class DeletionAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final String _primaryKeyColumnName;
  final Map<String, dynamic> Function(T) _valueMapper;
  final StreamController<String> _changeListener;

  DeletionAdapter(
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
        _primaryKeyColumnName = primaryKeyColumnName,
        _valueMapper = valueMapper,
        _changeListener = changeListener;

  Future<void> delete(final T item) async {
    await _delete(item);
  }

  Future<void> deleteList(final List<T> items) async {
    if (items.isEmpty) return;
    await _deleteList(items);
  }

  Future<int> deleteAndReturnChangedRows(final T item) {
    return _delete(item);
  }

  Future<int> deleteListAndReturnChangedRows(final List<T> items) async {
    if (items.isEmpty) return 0;
    return _deleteList(items);
  }

  Future<int> _delete(final T item) async {
    final dynamic primaryKey = _valueMapper(item)[_primaryKeyColumnName];

    final result = await _database.delete(
      _entityName,
      where: '$_primaryKeyColumnName = ?',
      whereArgs: <dynamic>[primaryKey],
    );
    if (_changeListener != null && result != 0) {
      _changeListener.add(_entityName);
    }
    return result;
  }

  Future<int> _deleteList(final List<T> items) async {
    final batch = _database.batch();
    for (final item in items) {
      final dynamic primaryKey = _valueMapper(item)[_primaryKeyColumnName];

      batch.delete(
        _entityName,
        where: '$_primaryKeyColumnName = ?',
        whereArgs: <dynamic>[primaryKey],
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
