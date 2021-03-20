import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class DatabaseProcessorError {
  final ClassElement _classElement;

  DatabaseProcessorError(final ClassElement classElement)
      : _classElement = classElement;

  InvalidGenerationSourceError get versionIsMissing {
    return InvalidGenerationSourceError(
      'No version for this database specified even though it is required.',
      todo:
          'Add version to annotation. e.g. @Database(version: 1, entities: [Person, Dog])',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get versionIsBelowOne {
    return InvalidGenerationSourceError(
      'The version of the database has to be a positive number.',
      todo:
          'Adjust the version of the annotation. e.g. @Database(version: 1, entities: [Person, Dog])',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError get noEntitiesDefined {
    return InvalidGenerationSourceError(
      'There are no entities added to the database annotation.',
      todo:
          'Add entities the annotation. e.g. @Database(version:1, entities: [Person, Dog])',
      element: _classElement,
    );
  }
}
