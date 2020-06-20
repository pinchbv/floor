import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class QueryProcessorError {
  final MethodElement _methodElement;
  //final Element _annotation;

  QueryProcessorError(final MethodElement methodElement)
      : assert(methodElement != null),
        _methodElement = methodElement;

  //TODO use annotationElement
  InvalidGenerationSourceError fromParsingError(ParsingError error) {
    return InvalidGenerationSourceError(
      'The query contained errors: ${error.message}',
      element: _methodElement,
    );
  }

  //TODO use annotationElement
  InvalidGenerationSourceError fromAnalysisError(AnalysisError error) {
    return InvalidGenerationSourceError(
      'The query contained errors: ${error.message}',
      element: _methodElement,
    );
  }

  //TODO use annotationElement?
  InvalidGenerationSourceError queryParameterMissingInMethod(
      ColonNamedVariable variable) {
    throw InvalidGenerationSourceError(
        'Invalid named variable $variable in statement of `@Query` annotation does not exist in the method parameters.',
        todo:
            'Please add a method parameter for the variable $variable with the name ${variable.name.substring(1)}.',
        element: _methodElement);
  }

  //TODO use annotationElement
  InvalidGenerationSourceError shouldNotHaveNumberedVars(NumberedVariable e) {
    throw InvalidGenerationSourceError(
        'Invalid numbered variable $e in statement of `@Query` annotation. '
        'Statements used in floor can only have named parameters with colons.',
        todo:
            'Please use a named variable (`:name`) instead of numbered variables (`?` or `?3`).',
        element: _methodElement);
  }
}
