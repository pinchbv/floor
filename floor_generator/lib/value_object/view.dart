import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';

class View extends Queryable {
  final String query;

  View(
    ClassElement classElement,
    String name,
    List<Field> fieldsQuery,
    List<Field> fieldsDataBase,
    List<Field> fieldsAll,
    this.query,
    String constructor,
  ) : super(classElement: classElement, name: name, fieldsQuery: fieldsQuery, fieldsDataBase: fieldsDataBase, fieldsAll: fieldsAll, constructor: constructor);

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
          const ListEquality<Field>().equals(fieldsAll, other.fieldsAll) &&
          const ListEquality<Field>().equals(fieldsQuery, other.fieldsQuery) &&
          const ListEquality<Field>().equals(fieldsDataBase, other.fieldsDataBase) &&
          query == other.query &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      fieldsAll.hashCode ^
      fieldsQuery.hashCode ^
      fieldsDataBase.hashCode ^
      query.hashCode ^
      constructor.hashCode;

  @override
  String toString() {
    return 'View{classElement: $classElement, name: $name, fieldsAll: $fieldsAll, fieldsQuery: $fieldsQuery, fieldsDataBase: $fieldsDataBase, query: $query, constructor: $constructor}';
  }
}
