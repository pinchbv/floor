import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/model/column.dart';

class Entity {
  final ClassElement clazz;

  Entity(this.clazz);

  String get name => clazz.displayName;

  List<FieldElement> get fields => clazz.fields;

  List<Column> get columns {
    return fields.map((field) => Column(field)).toList();
  }
}
