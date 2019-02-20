abstract class SupportedType {
  static const STRING = 'String';
  static const BOOL = 'bool';
  static const INT = 'int';
  static const DOUBLE = 'double';
}

abstract class Annotation {
  static const ENTITY = 'Entity';
  static const DATABASE = 'Database';
  static const COLUMN_INFO = 'ColumnInfo';
  static const PRIMARY_KEY = 'PrimaryKey';
  static const TRANSACTION = '_Transaction';

  static const QUERY = 'Query';
  static const INSERT = 'Insert';
  static const UPDATE = 'Update';
  static const DELETE = 'Delete';
}

abstract class AnnotationField {
  static const QUERY_VALUE = 'value';
  static const PRIMARY_KEY_AUTO_GENERATE = 'autoGenerate';

  static const COLUMN_INFO_NAME = 'name';
  static const COLUMN_INFO_NULLABLE = 'nullable';

  static const ENTITY_TABLE_NAME = 'tableName';
  static const ENTITY_FOREIGN_KEYS = 'foreignKeys';
}

abstract class ForeignKeyField {
  static const ENTITY = 'entity';
  static const CHILD_COLUMNS = 'childColumns';
  static const PARENT_COLUMNS = 'parentColumns';
  static const ON_UPDATE = 'onUpdate';
  static const ON_DELETE = 'onDelete';
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
