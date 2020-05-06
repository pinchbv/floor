import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/src/analysis/analysis.dart';

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

  InvalidGenerationSourceError parseErrorFromSqlparser(ParsingError parsingError) {
    return InvalidGenerationSourceError(
        'The following error occurred while parsing the SQL-Statement in ${_classElement.displayName}: ${parsingError.message}',
        element: _classElement
    );
  }

  InvalidGenerationSourceError lintErrorFromSqlparser(AnalysisError lintingError) {
    return InvalidGenerationSourceError(
        'The following error occurred while analyzing the SQL-Statement in ${_classElement.displayName}: ${lintingError.message}',
        element: _classElement
    );
  }

  InvalidGenerationSourceError nullableMismatch(String columnName, String fieldName) {
    // TODO sqlparser is nulltype and field is not nullable

    return null;
  }
}
