import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_analyzer/visitors.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class QueryProcessor extends Processor<Query> {
  final QueryProcessorError _processorError;

  final String _query;

  final AnalyzerEngine _engine;

  final List<ParameterElement> _parameters;

  QueryProcessor(MethodElement methodElement, this._query, this._engine)
      : assert(methodElement != null),
        assert(_query != null),
        assert(_engine != null),
        _processorError = QueryProcessorError(methodElement),
        _parameters = methodElement.parameters;

  @override
  Query process() {
    final analyzeContext = _validate();

    final listParameters = <ListParameter>[];

    final newQuery = _processParameters(analyzeContext, listParameters);

    _assertNoNamedVarsLeft(newQuery);

    return Query(
      newQuery,
      listParameters,
      _getOutputColumnTypes(analyzeContext),
      _getDependencies(analyzeContext.root),
      _getAffected(analyzeContext.root),
    );
  }

  AnalysisContext _validate() {
    // parse query,
    final parsed = _engine.inner.parse(_query);

    // throw errors
    if (parsed.errors.isNotEmpty) {
      throw _processorError.fromParsingError(parsed.errors.first);
    }

    //TODO first walk variables and search for missing ones here?

    // analyze query with named parameters only
    final analyzed = _engine.inner.analyzeParsed(parsed,
        stmtOptions: AnalyzeStatementOptions(
            namedVariableTypes: Map.fromEntries(_parameters.map((param) =>
                MapEntry(':${param.name}',
                    _getSqlparserType(param, flattenLists: true))))));
    // throw errors
    if (analyzed.errors.isNotEmpty) {
      throw _processorError.fromAnalysisError(analyzed.errors.first);
    }
    return analyzed;
  }

  String _processParameters(
      AnalysisContext ctx, List<ListParameter> listParameters) {
    final indices = <String, int>{};
    final fixedParameters = <String>{};
    // map parameters to index (1-based) or 0 (=list)
    int currentIndex = 1;
    for (final parameter in _parameters) {
      if (parameter.type.isDartCoreList) {
        indices[':${parameter.name}'] = 0;
      } else {
        fixedParameters.add(parameter.name);
        indices[':${parameter.name}'] = currentIndex++;
      }
    }

    // get List of query variables via VariableVisitor
    final visitor = VariableVisitor(_processorError,
        checkIfVariableExists: indices.keys.toSet(), numberedVarsAllowed: false)
      ..visitStatement(ctx.root, null);

    // reverse List and (1-x)replace var name with parameter or(0) map span to name
    final newQuery = StringBuffer();
    int currentLast = 0;
    for (final v in visitor.variables) {
      newQuery.write(_query.substring(currentLast, v.firstPosition));
      final varIndexInMethod = indices[v.name];
      if (varIndexInMethod > 0) {
        newQuery.write('?');
        newQuery.write(varIndexInMethod);
      } else {
        listParameters.add(ListParameter(newQuery.length, v.name.substring(1)));
        newQuery.write(varlistPlaceholder);
      }
      currentLast = v.lastPosition;
    }
    newQuery.write(_query.substring(currentLast));
    return newQuery.toString();
  }

  Set<Entity> _getDependencies(AstNode root) {
    return findReferencedTablesOrViews(root)
        // Find indirect dependencies for referenced Queryables
        .expand((e) => _engine.dependencies.indirectDependencies(e.name))
        // Find the according Queryables to their name
        .map((name) => _engine.registry[name])
        // Views cannot be updated via insert/delete/update, so we will ignore them.
        .whereType<Entity>()
        .toSet();
  }

  Set<String> _getAffected(AstNode root) {
    return findWrittenTables(root).map((e) => e.table.name).toSet();
  }

  void _assertNoNamedVarsLeft(String newQuery) {
    //TODO
  }

  List<SqlResultColumn> _getOutputColumnTypes(AnalysisContext analysisContext) {
    if (analysisContext.root is BaseSelectStatement) {
      return (analysisContext.root as BaseSelectStatement)
          .resolvedColumns
          .map((c) => SqlResultColumn(c.name, analysisContext.typeOf(c)))
          .toList(growable: false);
    } else {
      // any other statement where SQLite does not return anything.
      return [];
    }
  }
}

/// converts a dart element type description to a nullable type
/// compatible with sqlparser.
@nonNull
ResolvedType _getSqlparserType(VariableElement parameter,
    {bool flattenLists = false}) {
//TODO typeconverters
  var type = parameter.type;
  if (flattenLists && type.isDartCoreList) {
    type = type.flatten();
  }
  if (type.isDartCoreInt) {
    return const ResolvedType(type: BasicType.int, nullable: true);
  } else if (type.isDartCoreString) {
    return const ResolvedType(type: BasicType.text, nullable: true);
  } else if (type.isDartCoreBool) {
    return const ResolvedType(
        type: BasicType.int, nullable: true, hint: IsBoolean());
  } else if (type.isDartCoreDouble) {
    return const ResolvedType(type: BasicType.real, nullable: true);
  } else if (type.isUint8List) {
    return const ResolvedType(type: BasicType.blob, nullable: true);
  }
  throw InvalidGenerationSourceError(
    'Column type is not supported for $type.',
    element: parameter,
  );
}
