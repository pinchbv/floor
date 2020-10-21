/// Set of conflict handling strategies for insert and update methods.
///
/// Check SQLite conflict documentation for details.
enum OnConflictStrategy {
  /// OnConflict strategy constant to replace the old data and continue the
  /// transaction.
  replace,

  /// OnConflict strategy constant to rollback the transaction.
  rollback,

  /// OnConflict strategy constant to abort the transaction.
  abort,

  /// OnConflict strategy constant to fail the transaction.
  fail,

  /// OnConflict strategy constant to ignore the conflict.
  ignore,
}
