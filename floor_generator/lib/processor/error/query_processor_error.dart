// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:source_gen/source_gen.dart';

class QueryProcessorError {
  final MethodElement _methodElement;

  QueryProcessorError(final MethodElement methodElement)
      : _methodElement = methodElement;

  ProcessorError unusedQueryMethodParameter(
    final ParameterElement parameterElement,
  ) {
    return ProcessorError(
      message: 'Query method parameters have to be used.',
      todo: 'Use ${parameterElement.displayName} in the query or remove it.',
      element: parameterElement,
    );
  }

  ProcessorError unknownQueryVariable(
    final String variableName,
  ) {
    return ProcessorError(
      message:
          'Query variable `$variableName` has to exist as a method parameter.',
      todo:
          'Provide $variableName as a method parameter or remove it from the query.',
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

  ProcessorError queryMethodParameterIsNullable(
    final ParameterElement parameterElement,
  ) {
    return ProcessorError(
      message: 'Query method parameters have to be non-nullable.',
      todo: 'Define ${parameterElement.displayName} as non-nullable.'
          '\nIf you want to assert null, change your query to use the `IS NULL`/'
          '`IS NOT NULL` operator without passing a nullable parameter.',
      element: parameterElement,
    );
  }
}
