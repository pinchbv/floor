/// Marks a field as an embedded object.
class Embedded {
  /// Specifies a prefix to prepend the column names of the fields in the embedded fields.
  final String prefix;

  /// Marks a field as an embedded object.
  const Embedded([this.prefix = '']);
}

/// Marks a field as an embedded object.
///
/// Defaults prefix to empty String.
const embedded = Embedded();
