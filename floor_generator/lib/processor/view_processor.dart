import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_analyzer/type_checker.dart';
import 'package:floor_generator/processor/query_analyzer/visitors.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:sqlparser/sqlparser.dart' as sqlparser;

class ViewProcessor extends QueryableProcessor<View> {
  final ViewProcessorError _processorError;

  final AnalyzerEngine _analyzerEngine;

  ViewProcessor(final ClassElement classElement, this._analyzerEngine)
      : _processorError = ViewProcessorError(classElement),
        super(classElement);

  @nonNull
  @override
  View process() {
    final fields = getFields();
    final name = _getName();
    final query = _getQuery();

    final sqlparserView = _checkAndConvert(query, name, fields);

    assertMatchingTypes(fields, sqlparserView.resolvedColumns, classElement);

    final view = View(
      classElement.displayName,
      name,
      fields,
      query,
      getConstructor(fields),
    );

    _analyzerEngine.registerView(view, sqlparserView);

    return view;
  }

  @nonNull
  String _getName() {
    return classElement
            .getAnnotation(annotations.DatabaseView)
            .getField(AnnotationField.viewName)
            ?.toStringValue() ??
        classElement.displayName;
  }

  @nonNull
  String _getQuery() {
    return classElement
        .getAnnotation(annotations.DatabaseView)
        .getField(AnnotationField.viewQuery)
        ?.toStringValue();
  }

  @nonNull
  sqlparser.View _checkAndConvert(
      String query, String name, List<Field> fields) {
    // parse query
    final parserCtx = _analyzerEngine.sqlEngine.parse(query);

    if (parserCtx.errors.isNotEmpty) {
      throw _processorError.parseErrorFromSqlparser(parserCtx.errors.first);
    }

    // check if query is a select statement
    if (!(parserCtx.rootNode is sqlparser.BaseSelectStatement)) {
      throw _processorError.missingSelectQuery;
    }

    _assertNoVariables(parserCtx.rootNode);

    // analyze query (derive types)
    final ctx = _analyzerEngine.sqlEngine.analyzeParsed(parserCtx);
    if (ctx.errors.isNotEmpty) {
      throw _processorError.analysisErrorFromSqlparser(ctx.errors.first);
    }

    // create a Parser node for sqlparser
    final viewStmt = sqlparser.CreateViewStatement(
      ifNotExists: true,
      viewName: name,
      columns: fields.map((f) => f.columnName).toList(growable: false),
      query: ctx.root as sqlparser.BaseSelectStatement,
    );

    // check if any issues occurred while parsing and analyzing the query,
    // such as a mismatch between the count of the result of the query and
    // the count of fields in the view class
    sqlparser.LintingVisitor(getDefaultEngineOptions(), ctx)
        .visitCreateViewStatement(viewStmt, null);
    if (ctx.errors.isNotEmpty) {
      throw _processorError.lintingErrorFromSqlparser(ctx.errors.first);
    }

    // let sqlparser convert the parser node into a sqlparser view
    return const sqlparser.SchemaFromCreateTable(moorExtensions: false)
        .readView(ctx, viewStmt);
  }

  void _assertNoVariables(sqlparser.AstNode query) {
    final visitor = VariableVisitor(null, numberedVarsAllowed: true)
      ..visitStatement(query, null);
    if (visitor.variables.isNotEmpty) {
      throw _processorError.unexpectedVariable(visitor.variables.first);
    }
    if (visitor.numberedVariables.isNotEmpty) {
      throw _processorError.unexpectedVariable(visitor.numberedVariables.first);
    }
  }
}
