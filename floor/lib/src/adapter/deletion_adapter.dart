import 'package:sqflite/sqflite.dart';

class DeletionAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final String _primaryKeyColumnName;
  final Map<String, dynamic> Function(T) _valueMapper;

  DeletionAdapter(
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
        _primaryKeyColumnName = primaryKeyColumnName,
        _valueMapper = valueMapper;

  Future<void> delete(final T item) async {
    await _delete(item);
  }

  Future<void> deleteList(final List<T> items) async {
    if (items.isEmpty) return;

    final batch = _database.batch();
    _deleteList(batch, items);
    await batch.commit(noResult: true);
  }

  Future<int> deleteAndReturnChangedRows(final T item) {
    return _delete(item);
  }

  Future<int> deleteListAndReturnChangedRows(final List<T> items) async {
    if (items.isEmpty) return 0;

    final batch = _database.batch();
    _deleteList(batch, items);
    return (await batch.commit(noResult: false))
        .cast<int>()
        .reduce((sum, element) => sum + element);
  }

  Future<int> _delete(final T item) {
    final int primaryKey = _valueMapper(item)[_primaryKeyColumnName];

    return _database.delete(
      _entityName,
      where: '$_primaryKeyColumnName = ?',
      whereArgs: <int>[primaryKey],
    );
  }

  void _deleteList(final Batch batch, final List items) {
    for (final item in items) {
      final int primaryKey = _valueMapper(item)[_primaryKeyColumnName];

      batch.delete(
        _entityName,
        where: '$_primaryKeyColumnName = ?',
        whereArgs: <int>[primaryKey],
      );
    }
  }
}
