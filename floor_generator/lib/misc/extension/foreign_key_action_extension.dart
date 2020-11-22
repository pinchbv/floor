import 'package:floor_annotation/floor_annotation.dart';
import 'package:floor_generator/misc/annotations.dart';

extension ForeignKeyActionExtension on ForeignKeyAction {
  @nonNull
  String toSql() {
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
      default: // can only match null
        throw ArgumentError('toSql() should not be called on a null value. '
            'This is a bug in floor.');
    }
  }
}
