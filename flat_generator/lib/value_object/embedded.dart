import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:flat_generator/value_object/field.dart';

class Embedded extends FieldBase {
  final List<Field> fields;
  final List<Embedded> embedded;
  final bool isNullable;

  Embedded(FieldElement fieldElement, String name, this.fields, this.embedded,
      this.isNullable)
      : super(fieldElement, name);

  ClassElement get classElement => fieldElement.type.element as ClassElement;

  /// Returns all fields including embedded objects fields
  List<Field> getAllFields() =>
      [...fields, ...embedded.map((e) => e.getAllFields()).flattened];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embedded &&
          runtimeType == other.runtimeType &&
          fieldElement == other.fieldElement &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          const ListEquality<Embedded>().equals(embedded, other.embedded);

  @override
  int get hashCode =>
      fieldElement.hashCode ^ fields.hashCode ^ embedded.hashCode;

  @override
  String toString() {
    return 'Embedded{fieldElement: $fieldElement, fields: $fields, embedded: $embedded';
  }
}
