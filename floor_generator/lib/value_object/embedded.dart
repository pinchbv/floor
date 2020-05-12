import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';

class Embedded {
  final FieldElement fieldElement;
  final List<Field> fields;

  ClassElement get classElement => fieldElement.type.element as ClassElement;

  Embedded(this.fieldElement, this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embedded &&
          runtimeType == other.runtimeType &&
          fieldElement == other.fieldElement &&
          const ListEquality<Field>().equals(fields, other.fields);

  @override
  int get hashCode => fieldElement.hashCode ^ fields.hashCode;

  @override
  String toString() {
    return 'Embedded{fieldElement: $fieldElement, fields: $fields';
  }
}
