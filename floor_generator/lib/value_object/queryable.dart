import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/field.dart';

abstract class Queryable {
  final ClassElement classElement;
  final String name;

  final List<Field> fieldsAll;
  final List<Field> fieldsDataBaseSchema;
  final List<Field> fieldsQuery;
  final String constructor;

  Queryable({required this.classElement, required this.name, required this.fieldsAll, required this.fieldsDataBaseSchema, required this.fieldsQuery, required this.constructor});
}
