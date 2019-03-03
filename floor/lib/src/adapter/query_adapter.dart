import 'package:sqflite/sqflite.dart';

/// This class knows how to execute database queries.
class QueryAdapter {
  final DatabaseExecutor _database;

  QueryAdapter(final DatabaseExecutor database)
      : assert(database != null),
        _database = database;

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
    await _database.rawQuery(sql);
  }
}
