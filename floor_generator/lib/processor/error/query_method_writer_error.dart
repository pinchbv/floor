import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodWriterError {
  final MethodElement _methodElement;

  QueryMethodWriterError(final MethodElement methodElement)
      : _methodElement = methodElement;

  InvalidGenerationSourceError queryMethodReturnType() {
    return InvalidGenerationSourceError(
      'Can not define return type',
      todo:
          'Add supported return type to your query. https://pinchbv.github.io/floor/daos/#queries',
      element: _methodElement,
    );
  }
}
