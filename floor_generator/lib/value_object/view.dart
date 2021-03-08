import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';

class View extends Queryable {
  final String query;

  View(
    ClassElement classElement,
    String name,
    List<Field> fields,
    this.query,
    String constructor,
  ) : super(classElement, name, fields, constructor);

  String getCreateViewStatement() {
    return 'CREATE VIEW IF NOT EXISTS `$name` AS $query';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is View &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          query == other.query &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      fields.hashCode ^
      query.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'View{classElement: $classElement, name: $name, fields: $fields, query: $query, constructor: $constructor}';
  }
}
