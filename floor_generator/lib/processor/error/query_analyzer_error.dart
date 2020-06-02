import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class QueryAnalyzerError {
  final MethodElement _methodElement;

  QueryAnalyzerError(final MethodElement methodElement)
      : assert(methodElement != null),
        _methodElement = methodElement;

  InvalidGenerationSourceError fromParsingError(ParsingError error) {
    return InvalidGenerationSourceError(
      'The query contained errors: ${error.message}',
      element: _methodElement,
    );
  }

  InvalidGenerationSourceError fromAnalysisError(AnalysisError error) {
    return InvalidGenerationSourceError(
      'The query contained errors: ${error.message}',
      element: _methodElement,
    );
  }
}
