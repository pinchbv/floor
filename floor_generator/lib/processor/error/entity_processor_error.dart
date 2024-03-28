import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class EntityProcessorError {
  final ClassElement _classElement;

  EntityProcessorError(final ClassElement classElement)
      : _classElement = classElement;

  InvalidGenerationSourceError get missingPrimaryKey {
    return InvalidGenerationSourceError(
      'There is no primary key defined on the entity ${_classElement.displayName}.',
      todo:
          'Define a primary key for this entity with @primaryKey/@PrimaryKey() '
          'or by using the primaryKeys field of @Entity().',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get primaryKeyNotFound {
    return InvalidGenerationSourceError(
      'Primary key not found for ${_classElement.displayName}.',
      todo: 'Make sure that all the primary keys you defined exist as columns.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get missingParentColumns {
    return InvalidGenerationSourceError(
      'No parent columns defined for foreign key.',
      todo: 'Add parent columns to the foreign key.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get missingChildColumns {
    return InvalidGenerationSourceError(
      'No child columns defined for foreign key.',
      todo: 'Add child columns to the foreign key.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get foreignKeyDoesNotReferenceEntity {
    return InvalidGenerationSourceError(
      "The foreign key doesn't reference an entity class.",
      todo: 'Make sure to add an entity to the foreign key. ',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get foreignKeyNoEntity {
    return InvalidGenerationSourceError(
      'No entity defined for foreign key',
      todo: 'Make sure to add an entity to the foreign key. ',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get missingIndexColumnName {
    return InvalidGenerationSourceError(
      'No index column name defined.',
      todo:
          "Make sure to add an index column name like: Index(values: ['foo'])').",
      element: _classElement,
    );
  }

  InvalidGenerationSourceError noMatchingColumn(
    final String columnName,
  ) {
    return InvalidGenerationSourceError(
      'No matching column found for the given index. (`$columnName`)',
      todo:
          "Make sure to add a correct index column name like: Index(values: ['foo'])').",
      element: _classElement,
    );
  }

  InvalidGenerationSourceError wrongForeignKeyAction(
      DartObject field, String triggerName) {
    return InvalidGenerationSourceError(
      'No ForeignKeyAction with the value $field exists for the $triggerName trigger.',
      todo:
          'Make sure to add a correct ForeignKeyAction like `ForeignKeyAction.noAction` or leave it out entirely.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get autoIncrementInWithoutRowid {
    return InvalidGenerationSourceError(
      'autoGenerate is not allowed in WITHOUT ROWID tables',
      todo:
          'Remove autoGenerate in @PrimaryKey() or withoutRowid in @Entity().',
      element: _classElement,
    );
  }
}
