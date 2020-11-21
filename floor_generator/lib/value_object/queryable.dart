// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/field.dart';

abstract class Queryable {
  final ClassElement classElement;
  final String name;
  final List<Field> fields;
  final String constructor;

  Queryable(this.classElement, this.name, this.fields, this.constructor);
}
