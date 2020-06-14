import 'package:floor_generator/misc/annotations.dart';

enum ForeignKeyAction { noAction, restrict, setNull, setDefault, cascade }

extension AnnotationConverter on ForeignKeyAction {
  @nonNull
  String get toSQL {
    switch (this) {
      case ForeignKeyAction.noAction:
        return 'NO ACTION';
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
      case ForeignKeyAction.cascade:
        return 'CASCADE';
      default:
        assert(false, 'Unexpected enum case $this');
        return null;
    }
  }

  static ForeignKeyAction fromInt(int i) {
    // the position of the value in this list has to match the
    // integer of the annotation.
    return <ForeignKeyAction>[
      ForeignKeyAction.noAction,
      ForeignKeyAction.restrict,
      ForeignKeyAction.setNull,
      ForeignKeyAction.setDefault,
      ForeignKeyAction.cascade
    ][i];
  }
}
