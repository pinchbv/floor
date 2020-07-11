import 'package:floor_generator/value_object/field.dart';

abstract class Queryable {
  final String className;
  final String name;
  final List<Field> fields;
  final String constructor;

  Queryable(this.className, this.name, this.fields, this.constructor);
}
