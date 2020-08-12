import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_analyzer/visitors.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/misc/type_utils.dart';
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

  /// Run sqlparser and parse and analyze the query and return the resulting
  /// analysis context for using the parse tree and analyzing the return types.
  /// Any parsing or analysis errors(e.g. unknown table) are thrown as errors
  ///
  /// Also checks if the parameters are matching the query.
  @nonNull
  AnalysisContext _validate() {
    // parse query,
    final parsed = _engine.sqlEngine.parse(_query);

    // throw errors
    if (parsed.errors.isNotEmpty) {
      throw _processorError.fromParsingError(parsed.errors.first);
    }

    // check if parameter names of method and query match and make sure that no
    // numbered variables were used
    _assertMatchingParameters(parsed.rootNode);

    // analyze query with named parameters only
    final analyzed = _engine.sqlEngine.analyzeParsed(parsed,
        stmtOptions: AnalyzeStatementOptions(
            namedVariableTypes: Map.fromEntries(_parameters.map((param) =>
                MapEntry(':${param.name}', _getSqlparserType(param))))));
    // throw errors
    if (analyzed.errors.isNotEmpty) {
      throw _processorError.fromAnalysisError(analyzed.errors.first);
    }
    return analyzed;
  }

  /// Processes the parameters used for the query, with the goal to be able to
  /// use provided parameters in arbitrary order and multiple times, while still
  /// checking correctness.
  ///
  /// It will write the detected parameters which provide a List<> to the given
  /// [listParametersOutput] variable to be able to create a way to process them
  /// at runtime.
  ///
  /// The rough algorithm:
  /// 1. for each normal parameter:
  ///    1.1 create a mapping from the parameter name to its position in the
  ///        dart method (don't count list parameters).
  ///    1.3 replace each usage of that parameter in the query string with a
  ///        numbered parameter (?X).
  /// 2. for each list parameter:
  ///    2.1 ensure that this parameter is enclosed by parentheses
  ///    2.2 replace each usage of this parameter with a placeholder and note
  ///        down the position within the new query.
  ///    2.3 store position and name in order of appearance into the
  ///        [listParametersOutput] variable to be processed later
  /// 3. Return the new query.
  ///
  /// Replacing the named variables with numbered ones is necessary for having
  /// maximum control over the parameters, since named variables also get an
  /// index assigned to them and then using variable lists will get complicated fast.
  /// Additionally, numbered parameters are not as well supported by sqflite.
  ///
  ///
  @nonNull
  String _processParameters(
      AnalysisContext ctx, List<ListParameter> listParametersOutput) {
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
    final visitor = VariableVisitor(_processorError, numberedVarsAllowed: false)
      ..visitStatement(ctx.root, null);

    // replace(1-x) var names with parameters or(0) map span to name
    final newQuery = StringBuffer();
    int currentLast = 0;
    for (final varToken in visitor.variables) {
      newQuery.write(_query.substring(currentLast, varToken.firstPosition));
      final varIndexInMethod = indices[varToken.name];
      if (varIndexInMethod > 0) {
        //normal variable
        newQuery.write('?');
        newQuery.write(varIndexInMethod);
      } else {
        //list variable
        if (!(varToken.parent is Parentheses || varToken.parent is Tuple)) {
          throw _processorError.listParameterMissingParentheses(varToken);
        }
        listParametersOutput
            .add(ListParameter(newQuery.length, varToken.name.substring(1)));
        newQuery.write(varlistPlaceholder);
      }
      currentLast = varToken.lastPosition;
    }
    newQuery.write(_query.substring(currentLast));
    return newQuery.toString();
  }

  /// Determine all [Entity]s this query (indirectly) relies on.
  @nonNull
  Set<Entity> _getDependencies(AstNode root) {
    return findReferencedTablesOrViews(root)
        // Find indirect dependencies for referenced Queryables
        .expand((e) => _engine.dependencyGraph.indirectDependencies(e.name))
        // Find the according Queryables to their name
        .map((name) => _engine.registry[name])
        // Views cannot be updated via insert/delete/update, so we will ignore them.
        .whereType<Entity>()
        .toSet();
  }

  /// Determine all the directly affected entities of this query and return
  /// their table names. Should be of size 0 (for SELECT queries) or of
  /// size 1 (for UPDATE,DELETE,CREATE,etc.) queries. Returns a set to be
  /// able to return more affected entities in the future (TODO #373)
  @nonNull
  Set<String> _getAffected(AstNode root) {
    return findWrittenTables(root).map((e) => e.table.name).toSet();
  }

  /// This assertion should always be successful, even with wrong input. If it
  /// isn't, then there is a bug within floors mechanism to handle `:var`s.
  void _assertNoNamedVarsLeft(String newQuery) {
    final parsed = _engine.sqlEngine.parse(newQuery);
    final visitor = VariableVisitor(_processorError, numberedVarsAllowed: true)
      ..visitStatement(parsed.rootNode, null);
    for (final v in visitor.variables) {
      if (v.name != varlistPlaceholder) {
        throw _processorError.unexpectedNamedVariableInTransformedQuery(v);
      }
    }
  }

  /// return the list of columns which are expected to be returned by the
  /// given query. This can be used for type checking.
  ///
  /// The columns will have a name and a type. Please be aware that some
  /// column types might not have been resolved ([SqlResultColumn.isResolved])
  @nonNull
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

  /// ensures that
  /// 1. All variable references in the statement are written as named variables
  ///    (`:variable`) and have a matching parameter with the same name and
  /// 2. All function parameters are used in the statement at least once
  ///
  /// The [statement] is represented by the top AstNode as parsed by sqlparser
  void _assertMatchingParameters(AstNode statement) {
    final parameterNames = _parameters.map((p) => p.displayName).toSet();

    final visitor = VariableVisitor(_processorError,
        numberedVarsAllowed: false, checkIfVariableExists: parameterNames)
      ..visitStatement(statement, null);

    final references =
        visitor.variables.map((v) => v.name.substring(1)).toSet();
    for (final param in _parameters) {
      if (!references.contains(param.displayName)) {
        throw _processorError.methodParameterMissingInQuery(param);
      }
    }
  }

  /// converts a dart element type description to a nullable type
  /// compatible with sqlparser.
  @nonNull
  ResolvedType _getSqlparserType(VariableElement parameter) {
    //TODO typeconverters
    var type = parameter.type;
    if (type.isDartCoreList) {
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
    throw _processorError.unsupportedParameterType(parameter, type);
  }
}
