import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:source_gen/source_gen.dart';

class RawQueryMethodProcessorError {
  final MethodElement _methodElement;

  RawQueryMethodProcessorError(final MethodElement methodElement)
      : _methodElement = methodElement;

  InvalidGenerationSourceError get queryArgumentsShouldBeSingle {
    return InvalidGenerationSourceError(
      'RawQuery methods should have 1 and only 1 parameter with type String or SQLiteQuery',
      todo: 'Make sure to supply one parameter per SQL query argument.',
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

  ProcessorError queryMethodParameterIsNullable(
    final ParameterElement parameterElement,
  ) {
    return ProcessorError(
      message: 'Query method parameters have to be non-nullable.',
      todo: 'Define ${parameterElement.displayName} as non-nullable.'
          '\nIf you want to assert null, change your query to use the `IS NULL`/'
          '`IS NOT NULL` operator without passing a nullable parameter.',
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
