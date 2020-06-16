import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/utils/find_referenced_tables.dart';

export 'package:sqlparser/utils/find_referenced_tables.dart' show TableWrite;

/// Finds all writes to a table that occur anywhere inside the [root] node or a
/// descendant.
///
/// The [root] node must have all its references resolved. This means that using
/// a node obtained via [SqlEngine.parse] directly won't report meaningful
/// results. Instead, use [SqlEngine.analyze] or [SqlEngine.analyzeParsed].
///
/// If you want to find all referenced tables, use [findReferencedTables]. If
/// you want to find writes (including their [UpdateKind]) and referenced
/// tables, constrct a [UpdatedTablesVisitor] manually.
/// Then, let it [RecursiveVisitor.visit] the [root] node. You can now use
/// [UpdatedTablesVisitor.writtenTables] and
/// [ReferencedTablesVisitor.foundTables]. This will only walk the ast once,
/// whereas calling this and [findReferencedTables] will require two walks.
///
Set<TableWrite> findWrittenTables(AstNode root) {
  return (UpdatedTablesVisitor()..visit(root, null)).writtenTables;
} //TODO dupe of upstream method

/// Finds all tables referenced in [root] or a descendant.
///
/// The [root] node must have all its references resolved. This means that using
/// a node obtained via [SqlEngine.parse] directly won't report meaningful
/// results. Instead, use [SqlEngine.analyze] or [SqlEngine.analyzeParsed].
///
/// If you want to use both [findWrittenTables] and this on the same ast node,
/// follow the advice on [findWrittenTables] to only walk the ast once.
Set<NamedResultSet> findReferencedTablesOrViews(AstNode root) {
  final visitor = (ReferencedTablesVisitor()..visit(root, null));
  return {...visitor.foundTables, ...visitor.foundViews};
} //TODO is the only function here, move to usage place
