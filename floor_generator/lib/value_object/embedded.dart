import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/fieldable.dart';

class Embedded extends Fieldable {
  final ClassElement classElement;
  final List<Field> fields;
  final List<Embedded> children;

  Embedded(FieldElement fieldElement, this.fields, this.children)
      : classElement = fieldElement.type.element as ClassElement,
        super(fieldElement);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embedded &&
          runtimeType == other.runtimeType &&
          fieldElement == other.fieldElement &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          const ListEquality<Embedded>().equals(children, other.children);

  @override
  int get hashCode => fieldElement.hashCode ^ fields.hashCode;

  @override
  String toString() {
    return 'Embedded{classElement: $classElement, fieldElement: $fieldElement, fields: $fields, children: $children';
  }
}
