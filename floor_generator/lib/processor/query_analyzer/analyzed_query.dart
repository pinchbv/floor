import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_analyzer/referenced_queryables_visitor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:sqlparser/sqlparser.dart' hide Queryable;

class AnalyzeResult {
  final AnalyzerEngine engine;

  final String processedQuery;

  final AnalysisContext analysisContext;

  //map name to int as start of span with fixed width
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
  Set<Entity> get dependencies => findReferencedTablesOrViews(
          analysisContext.root)
      // Find indirect dependencies for referenced Queryables
      .expand((e) => engine.dependencies.indirectDependencies(e.name))
      // Find the according Queryables to their name
      .map((name) => engine.registry[name])
      // Views cannot be updated via insert/delete/update, so we will ignore them.
      .whereType<Entity>()
      .toSet();

  SqlReturnType get outputTypes {
    if (analysisContext.root is BaseSelectStatement) {
      final stmt = analysisContext.root as BaseSelectStatement;

      return SqlReturnType.fromIterable(
          stmt.resolvedColumns.map((c) => analysisContext.typeOf(c).type.type));
    } else if (analysisContext.root is InsertStatement) {
      // insert statements can return the IDs of the inserted rows.
      return SqlReturnType([BasicType.int]);
    } else if (analysisContext.root is DeleteStatement ||
        analysisContext.root is UpdateStatement) {
      // update statements can return the number of affected rows.
      return SqlReturnType([BasicType.int], multipleRows: false);
    } else {
      // a different statement where we can't infer the type (e.g. CREATE).
      // As we can't infer the type, we also can't generate a converter,
      // so we expect an empty return type.
      return SqlReturnType([], multipleRows: false);
    }
  }
}

class SqlReturnType {
  /// The types of the returned columns in order.
  /// If the list is empty, the query can only return void/null.
  final List<BasicType> columnTypes;

  /// Signals if a query can only return a single Row
  /// (e.g. because it is a DELETE statement)
  final bool multipleRows;

  SqlReturnType(this.columnTypes, {this.multipleRows = true});

  SqlReturnType.fromIterable(Iterable<BasicType> types,
      {this.multipleRows = true})
      : assert(types != null),
        columnTypes = types.toList();
}
