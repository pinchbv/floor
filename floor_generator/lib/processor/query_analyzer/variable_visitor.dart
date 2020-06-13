import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

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
      throw InvalidGenerationSourceError(
          'Invalid named variable $e in statement of `@Query` annotation does not exist in the method parameters.',
          todo:
              'Please add a method parameter for the variable $e with the name ${e.name.substring(1)}.',
          element: _queryMethod);
    }
    variables.add(e);
    return super.visitNamedVariable(e, arg);
  }
}
