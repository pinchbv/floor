import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';

class View extends Queryable {
  final String query;

  View(
    String className,
    String name,
    List<Field> fields,
    this.query,
    String constructor,
  ) : super(className, name, fields, constructor);

  @nonNull
  String getCreateViewStatement() {
    return 'CREATE VIEW IF NOT EXISTS `$name` AS $query';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is View &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          name == other.name &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          query == other.query &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      className.hashCode ^
      name.hashCode ^
      fields.hashCode ^
      query.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'View{className: $className, name: $name, fields: $fields, query: $query, constructor: $constructor}';
  }
}
