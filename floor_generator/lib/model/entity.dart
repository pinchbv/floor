import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/column.dart';

class Entity {
  final ClassElement clazz;

  Entity(this.clazz);

  String get name {
    return clazz.metadata
            .firstWhere(isEntityAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.ENTITY_TABLE_NAME)
            .toStringValue() ??
        clazz.displayName;
  }

  List<FieldElement> get fields {
    return clazz.fields
        .where((field) => field.displayName != 'hashCode')
        .toList();
  }

  List<Column> get columns {
    return fields.map((field) => Column(field)).toList();
  }
}
