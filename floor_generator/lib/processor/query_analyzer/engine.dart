import 'package:floor_generator/processor/query_analyzer/converter.dart';
import 'package:floor_generator/processor/query_analyzer/dependency_graph.dart';
import 'package:floor_generator/processor/query_analyzer/visitors.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/view.dart' as floor;
import 'package:sqlparser/sqlparser.dart' hide Queryable;

const String varlistPlaceholder = ':varlist';

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

    registry[entity.name] = entity;
    //register dependencies

    final directDependencies = entity.foreignKeys
        .where((e) => e.canChangeChild)
        .map((e) => e.parentName);
    dependencies.add(entity.name, directDependencies);
  }

  void checkAndRegisterView(floor.View floorView) {
    registry[floorView.name] = floorView;

    final convertedView = floorView.asSqlparserView(inner);
    inner.registerView(convertedView);

    //register dependencies
    final references = findReferencedTablesOrViews(convertedView.definition);
    dependencies.add(floorView.name, references.map((e) => e.name));
  }
}
