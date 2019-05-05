abstract class AnnotationField {
  static const QUERY_VALUE = 'value';
  static const PRIMARY_KEY_AUTO_GENERATE = 'autoGenerate';
  static const ON_CONFLICT = 'onConflict';

  static const DATABASE_VERSION = 'version';
  static const DATABASE_ENTITIES = 'entities';

  static const COLUMN_INFO_NAME = 'name';
  static const COLUMN_INFO_NULLABLE = 'nullable';
  static const COLUMN_INFO_READ_ONLY = 'readOnly';

  static const ENTITY_TABLE_NAME = 'tableName';
  static const ENTITY_FOREIGN_KEYS = 'foreignKeys';
  static const ENTITY_INDICES = 'indices';
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

abstract class ForeignKeyAction {
  static const NO_ACTION = 1;
  static const RESTRICT = 2;
  static const SET_NULL = 3;
  static const SET_DEFAULT = 4;
  static const CASCADE = 5;
}

abstract class SqlType {
  static const INTEGER = 'INTEGER';
  static const TEXT = 'TEXT';
  static const REAL = 'REAL';
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
