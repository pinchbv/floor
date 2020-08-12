import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/query_analyzer/dependency_graph.dart';
import 'package:floor_generator/processor/query_analyzer/visitors.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/view.dart' as floor;
import 'package:sqlparser/sqlparser.dart' hide Queryable;

const varlistPlaceholder = ':varlist';

//todo single test for testing engine registrations and dependencies
//todo test dependency graph
//todo test visitors with example queries
//todo add tests
//TODO test: check converter by parallel construction: field, entity

@nonNull
EngineOptions getDefaultEngineOptions() => EngineOptions(
      useMoorExtensions: false,
      useLegacyTypeInference: false,
      enabledExtensions: const [],
    );

class AnalyzerEngine {
  final Map<String, Queryable> registry = {};

  final sqlEngine = SqlEngine(getDefaultEngineOptions());

  final dependencyGraph = DependencyGraph();

  void registerEntity(Entity entity) {
    sqlEngine.registerTable(_convertEntityToTable(entity));

    registry[entity.name] = entity;

    //register dependencies
    final directDependencies = entity.foreignKeys
        .where((e) => e.canChangeChild)
        .map((e) => e.parentName);
    dependencyGraph.add(entity.name, directDependencies);
  }

  void registerView(floor.View floorView, View convertedView) {
    sqlEngine.registerView(convertedView);

    registry[floorView.name] = floorView;

    //register dependencies
    final references = findReferencedTablesOrViews(convertedView.definition);
    dependencyGraph.add(floorView.name, references.map((e) => e.name));
  }

  /// Converts a floor [Entity] into a sqlparser [Table]
  @nonNull
  static Table _convertEntityToTable(Entity e) => Table(
        // table constraints like foreign keys or indices are omitted here
        // because they will not be needed for static analysis.
        name: e.name,
        resolvedColumns: e.fields
            .map((field) => TableColumn(
                  field.columnName,
                  ResolvedType(
                      type: sqlToBasicType[field.sqlType],
                      nullable: field.isNullable,
                      isArray: false,
                      hint: field.fieldElement.type.isDartCoreBool
                          ? const IsBoolean()
                          : null),
                ))
            .toList(growable: false),
        withoutRowId: e.withoutRowid,
      );
}
