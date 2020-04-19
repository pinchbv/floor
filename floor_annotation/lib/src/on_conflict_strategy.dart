/// Set of conflict handling strategies for insert and update methods.
///
/// Check SQLite conflict documentation for details.
abstract class OnConflictStrategy {
  /// OnConflict strategy constant to replace the old data and continue the
  /// transaction.
  static const replace = 1;

  /// OnConflict strategy constant to rollback the transaction.
  static const rollback = 2;

  /// OnConflict strategy constant to abort the transaction.
  static const abort = 3;

  /// OnConflict strategy constant to fail the transaction.
  static const fail = 4;

  /// OnConflict strategy constant to ignore the conflict.
  static const ignore = 5;
}
