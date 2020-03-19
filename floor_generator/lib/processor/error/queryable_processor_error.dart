import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class QueryableProcessorError {
  final ClassElement _classElement;

  QueryableProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get PROHIBITED_MIXIN_USAGE {
    return InvalidGenerationSourceError(
      'Entities and views are not allowed to inherit from mixins.',
      todo: 'Inline fields and remove mixin from class definition.',
      element: _classElement,
    );
  }
}
