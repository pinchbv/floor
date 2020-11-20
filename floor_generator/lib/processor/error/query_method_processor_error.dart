// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodProcessorError {
  final MethodElement _methodElement;

  QueryMethodProcessorError(final MethodElement methodElement)
      : assert(methodElement != null),
        _methodElement = methodElement;

  InvalidGenerationSourceError get noQueryDefined {
    return InvalidGenerationSourceError(
      "You didn't define a query.",
      todo: 'Define a query by adding SQL to the @Query() annotation.',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError get queryArgumentsAndMethodParametersDoNotMatch {
    return InvalidGenerationSourceError(
      'SQL query arguments and method parameters have to match.',
      todo: 'Make sure to supply one parameter per SQL query argument.',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError get doesNotReturnFutureNorStream {
    return InvalidGenerationSourceError(
      'All queries have to return a Future or Stream.',
      todo: 'Define the return type as Future or Stream.',
      element: _methodElement,
    );
  }
}
