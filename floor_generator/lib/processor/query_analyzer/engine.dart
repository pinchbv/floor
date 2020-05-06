import 'package:analyzer/dart/element/element.dart';
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



  AnalyzeResult analyzeQuery(String query, List<ParameterElement> parameters){


    return null;
  }
}