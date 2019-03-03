import 'package:sqflite/sqflite.dart';

class InsertionAdapter<T> {
  final DatabaseExecutor _database;
  final String _entityName;
  final Map<String, dynamic> Function(T) _valueMapper;

  InsertionAdapter(
    final DatabaseExecutor database,
    final String entityName,
    final Map<String, dynamic> Function(T) valueMapper,
  )   : assert(database != null),
        assert(entityName != null),
        assert(entityName.isNotEmpty),
        assert(valueMapper != null),
        _database = database,
        _entityName = entityName,
        _valueMapper = valueMapper;

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

    final batch = _database.batch();
    _insertList(batch, items, conflictAlgorithm);
    await batch.commit(noResult: true);
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

    final batch = _database.batch();
    _insertList(batch, items, conflictAlgorithm);
    return (await batch.commit(noResult: false)).cast<int>();
  }

  Future<int> _insert(final T item, final ConflictAlgorithm conflictAlgorithm) {
    return _database.insert(
      _entityName,
      _valueMapper(item),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  void _insertList(
    final Batch batch,
    final List<T> items,
    final ConflictAlgorithm conflictAlgorithm,
  ) {
    for (final item in items) {
      batch.insert(
        _entityName,
        _valueMapper(item),
        conflictAlgorithm: conflictAlgorithm,
      );
    }
  }
}
