import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:source_gen/source_gen.dart';

class ForeignKey {
  final ClassElement entityClass;
  final DartObject object;

  ForeignKey(this.entityClass, this.object);

  /// Returns the parent column name referenced with this foreign key.
  String getParentName(final LibraryReader library) {
    final entityClassName =
        object.getField(ForeignKeyField.ENTITY)?.toTypeValue()?.displayName ??
            (throw InvalidGenerationSourceError(
              'No entity defined for foreign key',
              element: entityClass,
            ));

    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map((clazz) => Entity(clazz))
        .firstWhere(
          (entity) => entity.clazz.displayName == entityClassName,
          orElse: () => throw InvalidGenerationSourceError(
                '$entityClassName is not an entity. Did you miss annotating the class with @Entity?',
                element: entityClass,
              ),
        )
        .name;
  }

  List<String> get childColumns {
    return _getColumns(ForeignKeyField.CHILD_COLUMNS) ??
        (throw InvalidGenerationSourceError(
          'No child columns defined for foreign key',
          element: entityClass,
        ));
  }

  List<String> get parentColumns {
    return _getColumns(ForeignKeyField.PARENT_COLUMNS) ??
        (throw InvalidGenerationSourceError(
          'No parent columns defined for foreign key',
          element: entityClass,
        ));
  }

  int get onUpdate => object.getField(ForeignKeyField.ON_UPDATE)?.toIntValue();

  int get onDelete => object.getField(ForeignKeyField.ON_DELETE)?.toIntValue();

  List<String> _getColumns(final String foreignKeyField) {
    return object
        .getField(foreignKeyField)
        ?.toListValue()
        ?.map((object) => object.toStringValue())
        ?.toList();
  }
}
