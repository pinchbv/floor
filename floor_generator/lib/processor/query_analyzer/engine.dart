import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/error/query_analyzer_error.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/view.dart' as floor;
import 'package:sqlparser/sqlparser.dart';

import 'analyzed_query.dart';
import 'converter.dart';
import 'dependency_graph.dart';
import 'referenced_queryables_visitor.dart';

EngineOptions getDefaultEngineOptions(){
  return EngineOptions(
    useMoorExtensions: false,
    useLegacyTypeInference: false,
    enabledExtensions: const [],
  );
}


class AnalyzerEngine{


  final Database context;

  final SqlEngine inner = SqlEngine(getDefaultEngineOptions());

  final DependencyGraph dependencies = DependencyGraph();

  AnalyzerEngine(this.context) {
    // the order is important here! The views might depend on the
    // tables (or other views) for type resolution.
    context.entities.forEach(registerEntity);
    context.views.forEach(registerView);
  }



  void registerEntity(Entity entity){
    inner.registerTable(entity.asTable());

    //register dependencies
    dependencies.add(entity.name, entity.foreignKeys.map((e) => e.parentName));
  }


  void registerView(floor.View floorView){
    final convertedView = floorView.asSqlparserView(inner);

    inner.registerView(convertedView);

    //register dependencies
    final references = findReferencedTablesOrViews(convertedView.definition);
    dependencies.add(floorView.name, references.map((e) => e.name));
  }



  AnalyzeResult analyzeQuery(String query, MethodElement method){

    // parse query,
    final parsed=inner.parse(query);

    // throw errors
    if(parsed.errors.isNotEmpty){
      throw QueryAnalyzerError(method).fromParsingError(parsed.errors.first);
    }

    final analyzed=inner.analyzeParsed(parsed,
        stmtOptions: _methodToNamedVariables(method));
    // analyze query with named parameters only
    // throw errors
    //
    // prepare variables in IN clauses  and substitute other `:xyz` variables with positional ones

    // re-parse query
    // check for errors(these are ours now)
    // use variablewalker to get new IN variables and spans
    //on demand: find dependencies
    //on demand: find write targets (if there)
    //on demand: get resolved types
    //on demand: test if type is matching
    //


    return null;
  }

  @nonNull
  static AnalyzeStatementOptions _methodToNamedVariables(@nonNull MethodElement method){
    final mapping = <String,ResolvedType>{};
    for(ParameterElement param in method.parameters){
      final type=_getSqlparserType(param);

      mapping.putIfAbsent('',ResolvedType(
        // dart can't reliably hint nullable types and setting this to true
        // would produce too many false positives when typechecking
        nullable: false,
        hint: TypeHint()
      );
    }
    method.parameters.map(_getSqlparserType)

    AnalyzeStatementOptions()
    //TODO
    return null;
  }


  @nonNull
  static ResolvedType _getSqlparserType(ParameterElement parameter) {
    parameter.
    final type = parameter.type;
    if (type.isDartCoreInt) {
      return ResolvedType(type: BasicType.int);
    } else if (type.isDartCoreString) {
      return SqlType.text;
    } else if (type.isDartCoreBool) {
      return SqlType.integer;
    } else if (type.isDartCoreDouble) {
      return SqlType.real;
    } else if (type.isUint8List) {
      return SqlType.blob;
    }
    throw InvalidGenerationSourceError(
      'Column type is not supported for $type.',
      element: parameter,
    );
  }

}