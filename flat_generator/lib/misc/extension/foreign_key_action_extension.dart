import 'package:flat_annotation/flat_annotation.dart';

extension ForeignKeyActionExtension on ForeignKeyAction {
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
    }
  }
}
