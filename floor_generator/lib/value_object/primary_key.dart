// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';

/// Primary key representation of an Entity
class PrimaryKey {
  final List<Field> fields;
  final bool autoGenerateId;

  PrimaryKey(this.fields, this.autoGenerateId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrimaryKey &&
          runtimeType == other.runtimeType &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          autoGenerateId == other.autoGenerateId;

  @override
  int get hashCode => fields.hashCode ^ autoGenerateId.hashCode;

  @override
  String toString() {
    return 'PrimaryKey{fields: $fields, autoGenerateId: $autoGenerateId}';
  }
}
