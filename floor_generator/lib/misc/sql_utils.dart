import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';

class SqlConstants {
  static const INTEGER = 'INTEGER';
  static const TEXT = 'TEXT';
  static const REAL = 'REAL';

  static const PRIMARY_KEY = 'PRIMARY KEY';
  static const AUTOINCREMENT = 'AUTOINCREMNT';
}

String getColumnType(DartType type) {
  if (isInt(type)) {
    return SqlConstants.INTEGER;
  } else if (isString(type)) {
    return SqlConstants.INTEGER;
  } else if (isBool(type)) {
    return SqlConstants.INTEGER;
  } else if (isDouble(type)) {
    return SqlConstants.REAL;
  }
  return null;
}
