import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class EmbeddedProcessorError {
  final ClassElement _classElement;

  EmbeddedProcessorError(final ClassElement classElement)
      : _classElement = classElement;

  InvalidGenerationSourceError get possibleCyclicEmbeddedDependency {
    return InvalidGenerationSourceError(
      'StackOverFlowError happened which can be a sign of cyclic embedded dependency when processing '
      '${_classElement.displayName}.',
      todo: 'Check for cyclic dependency between your nested embedded objects',
      element: _classElement,
    );
  }
}
