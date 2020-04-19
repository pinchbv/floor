import 'package:floor_annotation/src/on_conflict_strategy.dart';

/// Marks a method as an insert method.
class Insert {
  /// How to handle conflicts. Defaults to [OnConflictStrategy.abort].
  final int onConflict;

  /// Marks a method as an insert method.
  const Insert({this.onConflict = OnConflictStrategy.abort});
}

/// Marks a method as an insert method.
///
/// Defaults conflict strategy to [OnConflictStrategy.abort].
const insert = Insert();
