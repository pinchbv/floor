import 'package:floor_generator/misc/annotations.dart';

abstract class ForeignKeyAction {
  static const noAction = 1;
  static const restrict = 2;
  static const setNull = 3;
  static const setDefault = 4;
  static const cascade = 5;

  @nonNull
  static String getString(final int action) {
    switch (action) {
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
      case ForeignKeyAction.cascade:
        return 'CASCADE';
      case ForeignKeyAction.noAction:
      default:
        return 'NO ACTION';
    }
  }
}
