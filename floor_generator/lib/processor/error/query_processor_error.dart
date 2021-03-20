import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';

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

  ProcessorError queryMethodParameterIsListButVariableIsNot(
    final String varName,
  ) {
    final name = varName.substring(1);
    return ProcessorError(
      message:
          'The parameter $name should be referenced like a list (`x IN ($varName)`)',
      todo: 'Change the type of $name to not be a List<> or'
          'reference it with ` IN ($varName)` (including the parentheses).',
      element: _methodElement,
    );
  }

  ProcessorError queryMethodParameterIsNormalButVariableIsList(
    final String varName,
  ) {
    final name = varName.substring(1);
    return ProcessorError(
      message: 'The parameter $name should be referenced without `IN`',
      todo: 'Change the type of $name to be a List<> or'
          'reference it without `IN`, e.g. `IS $varName`.',
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
