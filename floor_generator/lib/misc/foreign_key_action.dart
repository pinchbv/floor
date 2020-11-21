// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
abstract class ForeignKeyAction {
  static const noAction = 1;
  static const restrict = 2;
  static const setNull = 3;
  static const setDefault = 4;
  static const cascade = 5;

  static String getString(final int? action) {
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
