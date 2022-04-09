import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/value_object/embedded.dart';
import 'package:flat_generator/value_object/field.dart';

abstract class Queryable {
  final ClassElement classElement;
  final String name;
  final List<Field> fields;
  final List<Embedded> embedded;
  final String constructor;

  Queryable(this.classElement, this.name, this.fields, this.embedded,
      this.constructor);
}
