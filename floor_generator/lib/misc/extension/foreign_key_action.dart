import 'package:floor_annotation/floor_annotation.dart';
import 'package:floor_generator/misc/annotations.dart';

extension ToSQL on ForeignKeyAction {
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
        return null;
    }
  }
}
