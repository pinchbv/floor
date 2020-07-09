import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class ViewProcessorError {
  final ClassElement _classElement;

  ViewProcessorError(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  InvalidGenerationSourceError get missingSelectQuery {
    return InvalidGenerationSourceError(
      'There is no SELECT query defined on the database view ${_classElement.displayName}.',
      todo:
          'Define a SELECT query for this database view with @DatabaseView(\'SELECT [...]\') ',
      element: _classElement,
    );
  }

  InvalidGenerationSourceError parseErrorFromSqlparser(
      ParsingError parsingError) {
    return InvalidGenerationSourceError(
        'The following error occurred while parsing the SQL-Statement in ${_classElement.displayName}: ${parsingError.toString()}',
        element: _classElement);
  }

  InvalidGenerationSourceError analysisErrorFromSqlparser(
      AnalysisError lintingError) {
    return InvalidGenerationSourceError(
        'The following error occurred while analyzing the SQL-Statement in ${_classElement.displayName}: ${lintingError.toString()}',
        element: _classElement);
  }

  InvalidGenerationSourceError lintingErrorFromSqlparser(
      AnalysisError lintingError) {
    return InvalidGenerationSourceError(
        'The following error occurred while comparing the DatabaseView to the SQL-Statement in ${_classElement.displayName}: ${lintingError.toString()}',
        element: _classElement);
  }

  InvalidGenerationSourceError unexpectedVariable(Variable variable) {
    return InvalidGenerationSourceError(
        'The query should not contain any variable references\n${variable.span.highlight()}',
        todo: 'Remove all variables by altering the query.',
        element: _classElement);
  }
}
