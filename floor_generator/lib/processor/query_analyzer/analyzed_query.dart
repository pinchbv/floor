import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_analyzer/referenced_queryables_visitor.dart';
import 'package:floor_generator/processor/query_analyzer/sqlite_types.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:sqlparser/sqlparser.dart' hide Queryable;

class AnalyzeResult {
  final AnalyzerEngine engine;

  final String processedQuery;

  final AnalysisContext analysisContext;

  //map name to int as start of span with fixed width
  //TODO should be a list to make sure it is sorted.
  final Map<int, String> listInsertionPositions;

  AnalyzeResult(this.processedQuery, this.listInsertionPositions,
      this.analysisContext, this.engine);

  /// The names of the entities this query will change directly
  Set<String> get affectedEntities {
    return findWrittenTables(analysisContext.root)
        .map((e) => e.table.name)
        .toSet();
  }

  /// The entities this query directly and indirectly depends on.
  /// If an entity of this set changes, it is possible that the output of
  /// this query also changes.
  Set<Entity> get dependencies {
    _dependenciesStored ??= findReferencedTablesOrViews(analysisContext.root)
        // Find indirect dependencies for referenced Queryables
        .expand((e) => engine.dependencies.indirectDependencies(e.name))
        // Find the according Queryables to their name
        .map((name) => engine.registry[name])
        // Views cannot be updated via insert/delete/update, so we will ignore them.
        .whereType<Entity>()
        .toSet();
    return _dependenciesStored;
  }

  Set<Entity> _dependenciesStored;

  List<SqlResultColumn> get outputTypes {
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
