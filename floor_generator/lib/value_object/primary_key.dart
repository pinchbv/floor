import 'package:floor_generator/value_object/field.dart';

/// Primary key representation of an Entity
class PrimaryKey {
  final Field field;
  final bool autoGenerateId;

  PrimaryKey(this.field, this.autoGenerateId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrimaryKey &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          autoGenerateId == other.autoGenerateId;

  @override
  int get hashCode => field.hashCode ^ autoGenerateId.hashCode;

  @override
  String toString() {
    return 'PrimaryKey{field: $field, autoGenerateId: $autoGenerateId}';
  }
}
