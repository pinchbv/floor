import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_analyzer_error.dart';
import 'package:floor_generator/processor/query_analyzer/variable_visitor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/view.dart' as floor;
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

import 'analyzed_query.dart';
import 'converter.dart';
import 'dependency_graph.dart';
import 'referenced_queryables_visitor.dart';

EngineOptions getDefaultEngineOptions() {
  return EngineOptions(
    useMoorExtensions: false,
    useLegacyTypeInference: false,
    enabledExtensions: const [],
  );
}

class AnalyzerEngine {
  final Map<String, Queryable> registry = {};

  final SqlEngine inner = SqlEngine(getDefaultEngineOptions());

  final DependencyGraph dependencies = DependencyGraph();

  AnalyzerEngine();

  void registerEntity(Entity entity) {
    inner.registerTable(entity.asTable());

    registry[entity.name] = entity as Queryable;
    //register dependencies

    final directDependencies = entity.foreignKeys
        .where((e) => e.canChangeChild)
        .map((e) => e.parentName);
    dependencies.add(entity.name, directDependencies);
  }

  void checkAndRegisterView(floor.View floorView) {
    registry[floorView.name] = floorView as Queryable;

    final convertedView = floorView.asSqlparserView(inner);
    inner.registerView(convertedView);

    //register dependencies
    final references = findReferencedTablesOrViews(convertedView.definition);
    dependencies.add(floorView.name, references.map((e) => e.name));
  }

  AnalyzeResult analyzeQuery(String query, MethodElement method) {
    // parse query,
    final parsed = inner.parse(query);

    // throw errors
    if (parsed.errors.isNotEmpty) {
      throw QueryAnalyzerError(method).fromParsingError(parsed.errors.first);
    }

    // analyze query with named parameters only
    final analyzed = inner.analyzeParsed(parsed,
        stmtOptions: _methodToNamedVariables(method));
    // throw errors
    if (analyzed.errors.isNotEmpty) {
      throw QueryAnalyzerError(method).fromAnalysisError(analyzed.errors.first);
    }

    // prepare variables in IN clauses  and substitute other `:xyz` variables with positional ones
    final output = _generateNewStatement(query, analyzed, method);

    //todo restructure and clean up
    // re-parse query
    // check for errors(these are ours now)
    // use variablewalker to get new IN variables and spans
    //on demand: find dependencies
    //on demand: find write targets (if there)
    //on demand: get resolved types
    //on demand: test if type is matching

    return output;
  }

  @nonNull
  static AnalyzeStatementOptions _methodToNamedVariables(
      @nonNull MethodElement method) {
    return AnalyzeStatementOptions(
        namedVariableTypes: Map.fromEntries(method.parameters.map((param) =>
            MapEntry(':${param.name}',
                _getSqlparserType(param, flattenLists: true)))));
  }

  /// converts a dart element type description to a nullable type
  /// compatible with sqlparser.
  @nonNull
  static ResolvedType _getSqlparserType(VariableElement parameter,
      {bool flattenLists = false}) {
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

  AnalyzeResult _generateNewStatement(
      String query, AnalysisContext ctx, MethodElement method) {
    final parameters = method.parameters;
    final indices = <String, int>{};
    final fixedParameters = <String>{};
    // map parameters to index (1-based) or 0 (=list)
    int currentIndex = 1;
    for (final parameter in parameters) {
      if (parameter.type.isDartCoreList) {
        indices[':${parameter.name}'] = 0;
      } else {
        fixedParameters.add(parameter.name);
        indices[':${parameter.name}'] = currentIndex++;
      }
    }

    // get List of query variables via VariableVisitor
    final visitor = VariableVisitor(method,
        checkIfVariableExists: indices.keys, numberedVarsAllowed: false)
      ..visitStatement(ctx.root, null);
    final variables = visitor.variables;

    // reverse List and (1-x)replace var name with parameter or(0) map span to name
    final newQuery = StringBuffer();
    int currentLast = 0;
    final listPositions = <int, String>{};
    for (final v in variables) {
      newQuery.write(query.substring(currentLast, v.firstPosition));
      final varIndexInMethod = indices[v.name];
      if (varIndexInMethod > 0) {
        newQuery.write('?');
        newQuery.write(varIndexInMethod);
      } else {
        listPositions[newQuery.length] = v.name.substring(1);
        newQuery.write(':varlist');
      }
      currentLast = v.lastPosition;
    }
    newQuery.write(query.substring(currentLast));

    return AnalyzeResult(newQuery.toString(), listPositions, ctx, this);
  }
}
