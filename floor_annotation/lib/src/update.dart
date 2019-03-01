import 'package:floor_annotation/src/on_conflict_strategy.dart';

/// Marks a method as an update method.
class Update {
  /// How to handle conflicts. Defaults to [OnConflictStrategy.ABORT].
  final int onConflict;

  /// Marks a method as an update method.
  const Update({this.onConflict = OnConflictStrategy.ABORT});
}

/// Marks a method as an update method.
///
/// Defaults conflict strategy to [OnConflictStrategy.ABORT].
const update = Update();
