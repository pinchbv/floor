// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class QueryableProcessorError {
  final ClassElement _classElement;

  QueryableProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  InvalidGenerationSourceError get prohibitedMixinUsage {
    return InvalidGenerationSourceError(
      'Entities and views are not allowed to inherit from mixins.',
      todo: 'Inline fields and remove mixin from class definition.',
      element: _classElement,
    );
  }
}
