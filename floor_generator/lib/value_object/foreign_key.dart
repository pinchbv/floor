import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

class ForeignKey {
  final ClassElement entityClass;
  final DartObject object;

  ForeignKey(this.entityClass, this.object);

  String getDefinition(final LibraryReader library) {
    final onUpdateAction = _getAction(_onUpdate);
    final onDeleteAction = _getAction(_onDelete);

    return 'FOREIGN KEY (${_childColumns.join(', ')}) '
        ' REFERENCES `${_getParentName(library)}` (${_parentColumns.join(', ')})'
        ' ON UPDATE $onUpdateAction'
        ' ON DELETE $onDeleteAction';
  }

  /// Returns the parent column name referenced with this foreign key.
  String _getParentName(final LibraryReader library) {
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

  List<String> get _childColumns {
    final columns = _getColumns(ForeignKeyField.CHILD_COLUMNS);
    if (columns.isEmpty) {
      throw InvalidGenerationSourceError(
        'No child columns defined for foreign key',
        element: entityClass,
      );
    }
    return columns;
  }

  List<String> get _parentColumns {
    final columns = _getColumns(ForeignKeyField.PARENT_COLUMNS);
    if (columns.isEmpty) {
      throw InvalidGenerationSourceError(
        'No parent columns defined for foreign key',
        element: entityClass,
      );
    }
    return columns;
  }

  int get _onUpdate => object.getField(ForeignKeyField.ON_UPDATE)?.toIntValue();

  int get _onDelete => object.getField(ForeignKeyField.ON_DELETE)?.toIntValue();

  String _getAction(final int action) {
    switch (action) {
      case ForeignKeyAction.RESTRICT:
        return 'RESTRICT';
      case ForeignKeyAction.SET_NULL:
        return 'SET_NULL';
      case ForeignKeyAction.SET_DEFAULT:
        return 'SET_DEFAULT';
      case ForeignKeyAction.CASCADE:
        return 'CASCADE';
      case ForeignKeyAction.NO_ACTION:
      default:
        return 'NO ACTION';
    }
  }

  List<String> _getColumns(final String foreignKeyField) {
    return object
            .getField(foreignKeyField)
            ?.toListValue()
            ?.map((object) => object.toStringValue())
            ?.toList() ??
        [];
  }
}
