import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';

/// Transient representation of a field in an Entity
class Transient {
  final List<Field> fields;

  Transient(this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transient &&
          runtimeType == other.runtimeType &&
          const ListEquality<Field>().equals(fields, other.fields);

  @override
  String toString() {
    return 'Transient{fields: $fields}';
  }
}
