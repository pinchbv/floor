import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/query_analyzer_error.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/utils/find_referenced_tables.dart';
export 'package:sqlparser/utils/find_referenced_tables.dart'
    show TableWrite, findWrittenTables;

class VariableVisitor extends RecursiveVisitor<void, void> {
  final MethodElement _queryMethod;

  final bool numberedVarsAllowed;

  final variables = <ColonNamedVariable>[];

  final numberedVariables = <NumberedVariable>[];

  final Set<String> checkIfVariableExists;

  VariableVisitor(this._queryMethod,
      {this.numberedVarsAllowed = false, this.checkIfVariableExists});

  @override
  void visitNumberedVariable(NumberedVariable e, void arg) {
    //error, no numbered variables allowed
    if (!numberedVarsAllowed) {
      throw InvalidGenerationSourceError(
          'Invalid numbered variable $e in statement of `@Query` annotation. '
          'Statements used in floor can only have named parameters with colons.',
          todo:
              'Please use a named variable (`:name`) instead of numbered variables (`?` or `?3`).',
          element: _queryMethod);
    }

    numberedVariables.add(e);
    return super.visitNumberedVariable(e, arg);
  }

  @override
  void visitNamedVariable(ColonNamedVariable e, void arg) {
    if (checkIfVariableExists != null &&
        !checkIfVariableExists.contains(e.name)) {
      throw QueryAnalyzerError(_queryMethod).queryParameterMissingInMethod(e);
    }
    variables.add(e);
    return super.visitNamedVariable(e, arg);
  }
}

/// Finds all tables or views referenced in [root] or a descendant.
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
}
