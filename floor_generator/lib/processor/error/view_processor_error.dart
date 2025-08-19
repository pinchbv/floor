import 'package:analyzer/dart/element/element2.dart';
import 'package:source_gen/source_gen.dart';

class ViewProcessorError {
  final ClassElement2 _classElement;

  ViewProcessorError(final ClassElement2 classElement) : _classElement = classElement;

  InvalidGenerationSourceError get missingQuery {
    return InvalidGenerationSourceError(
      'There is no SELECT query defined on the database view ${_classElement.displayName}.',
      todo: 'Define a SELECT query for this database view with @DatabaseView(\'SELECT [...]\') ',
      element: _classElement,
    );
  }
}
