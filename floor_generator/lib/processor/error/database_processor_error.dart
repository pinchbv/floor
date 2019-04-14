import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class DatabaseProcessorError {
  final ClassElement _classElement;

  DatabaseProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get VERSION_IS_MISSING {
    return InvalidGenerationSourceError(
      'No version for this database specified even though it is required.',
      todo:
          'Add version to annotation. e.g. @Database(version: 1, entities: [Person, Dog])',
      element: _classElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get VERSION_IS_BELOW_ONE {
    return InvalidGenerationSourceError(
      'The version of the database has to be a positive number.',
      todo:
          'Adjust the version of the annotation. e.g. @Database(version: 1, entities: [Person, Dog])',
      element: _classElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get NO_ENTITIES_DEFINED {
    return InvalidGenerationSourceError(
      'There are no entities added to the database annotation.',
      todo:
          'Add entities the annotation. e.g. @Database(version:1, entities: [Person, Dog])',
      element: _classElement,
    );
  }
}
