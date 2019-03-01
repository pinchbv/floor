/// Set of conflict handling strategies for insert and update methods.
///
/// Check SQLite conflict documentation for details.
abstract class OnConflictStrategy {
  /// OnConflict strategy constant to replace the old data and continue the
  /// transaction.
  static const REPLACE = 1;

  /// OnConflict strategy constant to rollback the transaction.
  static const ROLLBACK = 2;

  /// OnConflict strategy constant to abort the transaction.
  static const ABORT = 3;

  /// OnConflict strategy constant to fail the transaction.
  static const FAIL = 4;

  /// OnConflict strategy constant to ignore the conflict.
  static const IGNORE = 5;
}
