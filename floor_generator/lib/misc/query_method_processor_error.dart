import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodProcessorError {
  final MethodElement _methodElement;

  QueryMethodProcessorError(final MethodElement methodElement)
      : assert(methodElement != null),
        _methodElement = methodElement;

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get NO_QUERY_DEFINED {
    return InvalidGenerationSourceError(
      "You didn't define a query.",
      todo: 'Define a query by adding SQL to the @Query() annotation.',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError
      // ignore: non_constant_identifier_names
      get QUERY_ARGUMENTS_AND_METHOD_PARAMETERS_DO_NOT_MATCH {
    return InvalidGenerationSourceError(
      "You didn't define a query.",
      todo: 'Define a query by adding SQL to the @Query() annotation.',
      element: _methodElement,
    );
  }

  // ignore: non_constant_identifier_names
  InvalidGenerationSourceError get DOES_NOT_RETURN_FUTURE_NOR_STREAM {
    return InvalidGenerationSourceError(
      'All queries have to return a Future or Stream.',
      todo: 'Define the return type as Future or Stream.',
      element: _methodElement,
    );
  }
}
