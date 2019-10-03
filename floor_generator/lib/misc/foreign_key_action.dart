import 'package:floor_generator/misc/annotations.dart';

abstract class ForeignKeyAction {
  static const NO_ACTION = 1;
  static const RESTRICT = 2;
  static const SET_NULL = 3;
  static const SET_DEFAULT = 4;
  static const CASCADE = 5;

  @nonNull
  static String getString(final int action) {
    switch (action) {
      case ForeignKeyAction.RESTRICT:
        return 'RESTRICT';
      case ForeignKeyAction.SET_NULL:
        return 'SET NULL';
      case ForeignKeyAction.SET_DEFAULT:
        return 'SET DEFAULT';
      case ForeignKeyAction.CASCADE:
        return 'CASCADE';
      case ForeignKeyAction.NO_ACTION:
      default:
        return 'NO ACTION';
    }
  }
}
