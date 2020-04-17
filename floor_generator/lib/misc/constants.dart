abstract class AnnotationField {
  static const QUERY_VALUE = 'value';
  static const QUERY_IS_RAW = 'isRaw';
  static const PRIMARY_KEY_AUTO_GENERATE = 'autoGenerate';
  static const ON_CONFLICT = 'onConflict';

  static const DATABASE_VERSION = 'version';
  static const DATABASE_ENTITIES = 'entities';
  static const DATABASE_VIEWS = 'views';

  static const COLUMN_INFO_NAME = 'name';
  static const COLUMN_INFO_NULLABLE = 'nullable';

  static const ENTITY_TABLE_NAME = 'tableName';
  static const ENTITY_FOREIGN_KEYS = 'foreignKeys';
  static const ENTITY_INDICES = 'indices';
  static const ENTITY_PRIMARY_KEYS = 'primaryKeys';

  static const VIEW_NAME = 'viewName';
  static const VIEW_QUERY = 'query';
}

abstract class ForeignKeyField {
  static const ENTITY = 'entity';
  static const CHILD_COLUMNS = 'childColumns';
  static const PARENT_COLUMNS = 'parentColumns';
  static const ON_UPDATE = 'onUpdate';
  static const ON_DELETE = 'onDelete';
}

abstract class IndexField {
  static const NAME = 'name';
  static const UNIQUE = 'unique';
  static const VALUE = 'value';
}

abstract class SqlType {
  static const INTEGER = 'INTEGER';
  static const TEXT = 'TEXT';
  static const REAL = 'REAL';
  static const BLOB = 'BLOB';
}

abstract class OnConflictStrategy {
  static const REPLACE = 1;
  static const ROLLBACK = 2;
  static const ABORT = 3;
  static const FAIL = 4;
  static const IGNORE = 5;

  /// Sqflite conflict algorithm
  static String getConflictAlgorithm(final int strategy) {
    switch (strategy) {
      case OnConflictStrategy.REPLACE:
        return 'replace';
      case OnConflictStrategy.ROLLBACK:
        return 'rollback';
      case OnConflictStrategy.FAIL:
        return 'fail';
      case OnConflictStrategy.IGNORE:
        return 'ignore';
      case OnConflictStrategy.ABORT:
      default:
        return 'abort';
    }
  }
}
