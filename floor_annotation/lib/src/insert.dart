import 'package:floor_annotation/src/on_conflict_strategy.dart';

/// Marks a method as an insert method.
class Insert {
  /// How to handle conflicts. Defaults to [OnConflictStrategy.ABORT].
  final int onConflict;

  /// Marks a method as an insert method.
  const Insert({this.onConflict = OnConflictStrategy.ABORT});
}

/// Marks a method as an insert method.
///
/// Defaults conflict strategy to [OnConflictStrategy.ABORT].
const insert = Insert();
