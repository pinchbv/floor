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
  static const QUERY = 'Query';
}

abstract class AnnotationField {
  static const QUERY_VALUE = 'value';
  static const COLUMN_INFO_AUTO_GENERATE = 'autoGenerate';
}

abstract class SqlConstants {
  static const INTEGER = 'INTEGER';
  static const TEXT = 'TEXT';
  static const REAL = 'REAL';

  static const PRIMARY_KEY = 'PRIMARY KEY';
  static const AUTOINCREMENT = 'AUTOINCREMNT';
}
