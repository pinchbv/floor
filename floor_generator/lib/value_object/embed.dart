import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';

class Embed {
  final ClassElement classElement;
  final List<Field> fields;

  Embed(this.classElement, this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embed &&
          runtimeType == other.runtimeType &&
          const ListEquality<Field>().equals(fields, other.fields);

  @override
  int get hashCode => classElement.hashCode ^ fields.hashCode;

  @override
  String toString() {
    return 'Embed{classElement: $classElement, fields: $fields}';
  }
}
