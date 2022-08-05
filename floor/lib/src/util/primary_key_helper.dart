// ignore: avoid_classes_with_only_static_members
/// Utility functions for primary key actions
class PrimaryKeyHelper {
  /// Creates the WHERE clause in order to select the rows to be changed
  static String getWhereClause(final List<String> groupPrimaryKey) {
    return groupPrimaryKey.map((columnName) => '$columnName = ?').join(' AND ');
  }

  /// Obtains the primary key values
  static List<Object> getPrimaryKeyValues(
    final List<String> primaryKeys,
    final Map<String, Object?> values,
  ) {
    return primaryKeys.mapNotNull((key) => values[key]).toList();
  }
}

extension<T> on Iterable<T> {
  Iterable<R> mapNotNull<R>(R? Function(T element) transform) sync* {
    for (final element in this) {
      final transformed = transform(element);
      if (transformed != null) yield transformed;
    }
  }
}
