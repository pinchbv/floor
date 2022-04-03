import 'package:flat_annotation/src/on_conflict_strategy.dart';

/// Marks a method as an update method.
class Update {
  /// How to handle conflicts. Defaults to [OnConflictStrategy.abort].
  final OnConflictStrategy onConflict;

  /// Marks a method as an update method.
  const Update({this.onConflict = OnConflictStrategy.abort});
}

/// Marks a method as an update method.
///
/// Defaults conflict strategy to [OnConflictStrategy.abort].
const update = Update();
