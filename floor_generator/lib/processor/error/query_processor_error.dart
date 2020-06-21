import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class QueryProcessorError {
  final MethodElement _methodElement;

  QueryProcessorError(final MethodElement methodElement)
      : assert(methodElement != null),
        _methodElement = methodElement;

  InvalidGenerationSourceError fromParsingError(ParsingError error) {
    return InvalidGenerationSourceError(
      'The query contained parser errors: ${error.toString()}',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError fromAnalysisError(AnalysisError error) {
    return InvalidGenerationSourceError(
      'The query contained analyzer errors: ${error.toString()}',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError queryParameterMissingInMethod(
      ColonNamedVariable variable) {
    return InvalidGenerationSourceError(
        'Named variable in statement of `@Query` annotation should exist in the method parameters.\n${variable.span.highlight()}',
        todo:
            'Please add a method parameter for the variable `${variable.name}` with the name `${variable.name.substring(1)}`.',
        element: _methodElement);
  }

  InvalidGenerationSourceError methodParameterMissingInQuery(
      ParameterElement parameter) {
    return InvalidGenerationSourceError(
        'Method parameter should be referenced in statement of `@Query` annotation',
        todo:
            'Please reference this parameter with `:${parameter.displayName}` or remove it from the parameters.',
        element: parameter);
  }

  InvalidGenerationSourceError shouldNotHaveNumberedVars(NumberedVariable e) {
    return InvalidGenerationSourceError(
        'Invalid numbered variable in statement of `@Query` annotation. '
        'Statements used in floor should only have named parameters with colons.\n${e.span.highlight()}',
        todo:
            'Please use a named variable (`:name`) instead of numbered variables (`?` or `?3`).',
        element: _methodElement);
  }

  InvalidGenerationSourceError unexpectedNamedVariableInTransformedQuery(
      ColonNamedVariable v) {
    final builder = StringBuffer()
      ..writeln(
          'The named variable ${v.name} should not be in the transformed query string! This is a bug in floor.')
      ..writeln(v.span.highlight());
    return InvalidGenerationSourceError(builder.toString(),
        todo: 'Please report the bug and include some context.',
        element: _methodElement);
  }
}
