import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class ViewProcessorError {
  final ClassElement _classElement;

  ViewProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get MISSING_QUERY {
    return InvalidGenerationSourceError(
      'There is no SELECT query defined on the database view ${_classElement.displayName}.',
      todo:
          'Define a SELECT query for this database view with @DatabaseView(\'SELECT [...]\') ',
      element: _classElement,
    );
  }
}
