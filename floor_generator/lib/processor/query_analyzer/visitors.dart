import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/utils/find_referenced_tables.dart';

export 'package:sqlparser/utils/find_referenced_tables.dart'
    show TableWrite, findWrittenTables;

class VariableVisitor extends RecursiveVisitor<void, void> {
  final QueryProcessorError _processorError;

  final bool numberedVarsAllowed;

  final variables = <ColonNamedVariable>[];

  final numberedVariables = <NumberedVariable>[];

  final Set<String> checkIfVariableExists;

  VariableVisitor(this._processorError,
      {this.numberedVarsAllowed = false, this.checkIfVariableExists});

  @override
  void visitNumberedVariable(NumberedVariable e, void arg) {
    //error, no numbered variables allowed
    if (!numberedVarsAllowed) {
      throw _processorError.shouldNotHaveNumberedVars(e);
    }

    numberedVariables.add(e);
    return super.visitNumberedVariable(e, arg);
  }

  @override
  void visitNamedVariable(ColonNamedVariable e, void arg) {
    if (checkIfVariableExists != null &&
        !checkIfVariableExists.contains(e.name)) {
      throw _processorError.queryParameterMissingInMethod(e);
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
  final visitor = ReferencedTablesVisitor()..visit(root, null);
  return {...visitor.foundTables, ...visitor.foundViews};
}
