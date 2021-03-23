import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:source_gen/source_gen.dart';
import 'package:floor_generator/misc/type_utils.dart';

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

  InvalidGenerationSourceError twoForeignKeysForTheSameParentTable(ClassElement _classElement){
    return InvalidGenerationSourceError(
      'More than one link from the child table to the same parent table, it was not implemented for two or more fields to link to the child table.',
      todo: 'Open a issue to implement the feature.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError foreignKeyDoesNotReferenceEntity(ClassElement _classElement) {
    return InvalidGenerationSourceError(
      "The foreign key doesn't reference an entity class.",
      todo: 'Make sure to add an entity to the foreign key.',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get foreignKeyNoEntity {
    return InvalidGenerationSourceError(
      'No entity defined for foreign key',
      todo: 'Make sure to add an entity to the foreign key.',
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
    final List<String> columnNames,
  ) {
    return InvalidGenerationSourceError(
      'No matching columns found for the given index. (${columnNames.join(', ')})',
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

  ProcessorError saveMethodParameterIsNullable(
      final ParameterElement parameterElement,
      ) {
    return ProcessorError(
      message: 'Save method accepts only one parameter.',
      todo: 'Define the ${parameterElement.displayName} method with just one parameter.',
      element: parameterElement,
    );
  }

  ProcessorError saveMethodParameterHaveMoreOne(
      final MethodElement methodElement,
      ) {
    return ProcessorError(
      message: 'Insert method parameter have to be non-nullable.',
      todo: 'Define ${methodElement.displayName} as non-nullable.',
      element: methodElement,
    );
  }

  ProcessorError noMethodWithSaveAnnotation(
      final FieldElement field,
      ) {
    final type = field.type.isDartCoreList ? field.type.flatten() : field.type;
    return ProcessorError(
      message: 'The type ${type.getDisplayString(withNullability: false)} of fields with the @save annotation must be an entity.',
      todo: 'Remove the @save annotation or change the property type to an entity.',
      element: field,
    );
  }
}
