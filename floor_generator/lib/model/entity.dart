import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/column.dart';
import 'package:floor_generator/model/foreign_key.dart';
import 'package:source_gen/source_gen.dart';

class Entity {
  final ClassElement clazz;

  Entity(final this.clazz);

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

  Column get primaryKeyColumn {
    return columns.firstWhere(
      (column) => column.isPrimaryKey,
      orElse: () => throw InvalidGenerationSourceError(
            'There is no primary key defined on the entity $name.',
            element: clazz,
          ),
    );
  }

  List<ForeignKey> get foreignKeys {
    return clazz.metadata
        .firstWhere(isEntityAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.ENTITY_FOREIGN_KEYS)
        ?.toListValue()
        ?.map((object) => ForeignKey(clazz, object))
        ?.toList();
  }
}
