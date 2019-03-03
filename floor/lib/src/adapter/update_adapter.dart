import 'package:sqflite/sqflite.dart';

class UpdateAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final String _primaryKeyColumnName;
  final Map<String, dynamic> Function(T) _valueMapper;

  UpdateAdapter(
    final DatabaseExecutor database,
    final String entityName,
    final String primaryKeyColumnName,
    final Map<String, dynamic> Function(T) valueMapper,
  )   : assert(database != null),
        assert(entityName != null),
        assert(entityName.isNotEmpty),
        assert(primaryKeyColumnName != null),
        assert(primaryKeyColumnName.isNotEmpty),
        assert(valueMapper != null),
        _database = database,
        _entityName = entityName,
        _valueMapper = valueMapper,
        _primaryKeyColumnName = primaryKeyColumnName;

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

    final batch = _database.batch();
    _updateList(batch, items, conflictAlgorithm);
    await batch.commit(noResult: true);
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

    final batch = _database.batch();
    _updateList(batch, items, conflictAlgorithm);
    return (await batch.commit(noResult: false))
        .cast<int>()
        .reduce((sum, element) => sum + element);
  }

  Future<int> _update(final T item, final ConflictAlgorithm conflictAlgorithm) {
    final values = _valueMapper(item);
    final int primaryKey = values[_primaryKeyColumnName];

    return _database.update(
      _entityName,
      values,
      where: '$_primaryKeyColumnName = ?',
      whereArgs: <int>[primaryKey],
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  void _updateList(
    final Batch batch,
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) {
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
  }
}
