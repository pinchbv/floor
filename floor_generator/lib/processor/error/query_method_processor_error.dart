// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodProcessorError {
  final MethodElement _methodElement;

  QueryMethodProcessorError(final MethodElement methodElement)
      : _methodElement = methodElement;

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

  InvalidGenerationSourceError queryMethodParameterIsNull(
    final ParameterElement parameterElement,
  ) {
    return InvalidGenerationSourceError(
      'Query method parameters have to be non-nullable.',
      todo: 'Define ${parameterElement.displayName} as non-nullable.',
      element: _methodElement,
    );
  }

  ProcessorError get doesNotReturnNullableStream {
    return ProcessorError(
      message: 'Queries returning streams of single elements might emit null.',
      todo:
          'Make the method return a Stream of a nullable type e.g. Stream<Person?>.',
      element: _methodElement,
    );
  }

  ProcessorError get doesNotReturnNullableFuture {
    return ProcessorError(
      message: 'Queries returning single elements might return null.',
      todo:
          'Make the method return a Future of a nullable type e.g. Future<Person?>.',
      element: _methodElement,
    );
  }
}
