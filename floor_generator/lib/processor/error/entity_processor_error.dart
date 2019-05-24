import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class EntityProcessorError {
  final ClassElement _classElement;

  EntityProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get MISSING_PRIMARY_KEY {
    return InvalidGenerationSourceError(
      'There is no primary key defined on the entity ${_classElement.displayName}.',
      todo:
          'Define a primary key for this entity with @primaryKey/@PrimaryKey() '
          'or by using the primaryKeys field of @Entity().',
      element: _classElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get MISSING_PARENT_COLUMNS {
    return InvalidGenerationSourceError(
      'No parent columns defined for foreign key.',
      todo: 'Add parent columns to the foreign key.',
      element: _classElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get MISSING_CHILD_COLUMNS {
    return InvalidGenerationSourceError(
      'No child columns defined for foreign key.',
      todo: 'Add child columns to the foreign key.',
      element: _classElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get FOREIGN_KEY_DOES_NOT_REFERENCE_ENTITY {
    return InvalidGenerationSourceError(
        "The foreign key doesn't reference an entity class.",
        todo: 'Make sure to add an entity to the foreign key. ',
        element: _classElement);
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get FOREIGN_KEY_NO_ENTITY {
    return InvalidGenerationSourceError('No entity defined for foreign key',
        todo: 'Make sure to add an entity to the foreign key. ',
        element: _classElement);
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get MISSING_INDEX_COLUMN_NAME {
    return InvalidGenerationSourceError(
      'No index column name defined.',
      todo:
          "Make sure to add an index column name like: Index(values: ['foo'])').",
      element: _classElement,
    );
  }

  InvalidGenerationSourceError parameterTypeNotSupported(
    final ParameterElement parameterElement,
  ) {
    return InvalidGenerationSourceError(
      'The given constrcutor parameter type is not supported.',
      todo: 'Make sure to only use bool, String, int and double types.',
      element: parameterElement,
    );
  }

  InvalidGenerationSourceError noMatchingColumn(
    final List<String> columnNames,
  ) {
    return InvalidGenerationSourceError(
      'No matching columns found for the given index. (${columnNames.join(', ')})',
      todo:
          "Make sure to add a correct index column name like: Index(values: ['foo'])').",
      element: _classElement,
    );
  }
}
