/// Marks a field in an [Entity] as the primary key.
class PrimaryKey {
  /// Let SQLite auto generate the unique id.
  final bool autoGenerate;

  /// Defaults [autoGenerate] to false.
  const PrimaryKey({this.autoGenerate = false});
}

/// Marks a field in an [Entity] as the primary key.
///
/// Defaults the automatic generation of the primary key to `false`.
const primaryKey = PrimaryKey();
