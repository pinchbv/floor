import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/foreign_key_action.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:sqlparser/sqlparser.dart' hide View;
import 'package:sqlparser/sqlparser.dart' as sqlparser show View;

extension ToTableColumn on Field{
  static BasicType _toBasicType(String type){
    final mapping={
      SqlType.blob : BasicType.blob,
      SqlType.integer : BasicType.int,
      SqlType.real : BasicType.real,
      SqlType.text : BasicType.text,
    };
    return mapping[type];
  }

  TableColumn asTableColumn(){
    //todo map bool value or other non-basic types
    return TableColumn(
      columnName,
      ResolvedType(type: _toBasicType(sqlType), nullable: isNullable, isArray: false),
    );
  }
}

extension ToTable on Entity{
  static ReferenceAction _toReferenceAction(String action) {
    switch (action) {
      case 'RESTRICT':
        return ReferenceAction.restrict;
      case 'SET NULL':
        return ReferenceAction.setNull;
      case 'SET DEFAULT':
        return ReferenceAction.setDefault;
      case 'CASCADE':
        return ReferenceAction.cascade;
      case 'NO ACTION':
      default:
        return ReferenceAction.noAction;
    }
  }
    //  static ReferenceAction _toReferenceAction(int action){
//    switch (action) {
//      case ForeignKeyAction.restrict:
//        return ReferenceAction.restrict;
//      case ForeignKeyAction.setNull:
//        return ReferenceAction.setNull;
//      case ForeignKeyAction.setDefault:
//        return ReferenceAction.setDefault;
//      case ForeignKeyAction.cascade:
//        return ReferenceAction.cascade;
//      case ForeignKeyAction.noAction:
//      default:
//        return ReferenceAction.noAction;
//    }
//  }

  Table asTable(){
    final List<TableConstraint> constraints=[];

    //Add foreign keys
    constraints.addAll(foreignKeys.asMap().map((i,f)=>MapEntry(i,ForeignKeyTableConstraint(
      '${name}FKConstraint$i', //just a unique name
      columns: f.childColumns.map((col)=>Reference(tableName:name,columnName:col)),
      clause: ForeignKeyClause(
        foreignTable: TableReference(f.parentName),
        columnNames: f.parentColumns.map((col)=>Reference(tableName:f.parentName,columnName:col)),
        onDelete: _toReferenceAction(f.onDelete),
        onUpdate: _toReferenceAction(f.onUpdate),
      ),
    ))).values);

    //Add indices
    constraints.addAll(indices.asMap().map((i,index)=>MapEntry(i,KeyClause(
      '${name}IdxConstraint$i', //just a unique name
      indexedColumns: index.columnNames.map((col)=>Reference(tableName:name,columnName:col)),
      isPrimaryKey: false,
    ))).values);

    //Add primary key
    constraints.add(KeyClause(
      '${name}PrimaryKey', //just a unique name
      indexedColumns: primaryKey.fields.map((field)=>Reference(tableName:name,columnName:field.columnName)),
      isPrimaryKey: true,
    ));


    return Table(
      name: name,
      resolvedColumns: fields.map((field)=>field.asTableColumn()),
      tableConstraints: constraints,
    );
  }
}

extension ToSqlparserView on View{
  sqlparser.View asSqlparserView(SqlEngine engine){

    // parse query
    final parserCtx = engine.parse(query);

    if (parserCtx.errors.isNotEmpty){
      throw ViewProcessorError(classElement).parseErrorFromSqlparser(parserCtx.errors.first);
    }

    // check if query is a select statement
    if (!(parserCtx.rootNode is BaseSelectStatement)){
      throw ViewProcessorError(classElement).missingSelectQuery;
    }

    //TODO let VariableVisitor run and report an error if any were found

    // analyze query (derive types)
    final ctx=engine.analyzeParsed(parserCtx);

    // create a Parser node for sqlparser
    final viewStmt = CreateViewStatement(
      ifNotExists: true,
      viewName: name,
      columns: fields.map((f) => f.columnName),
      query: ctx.root as BaseSelectStatement,
    );

    // check if any issues occurred while parsing and analyzing the query,
    // such as a mismatch between the count of the result of the query and
    // the count of fields in the view class
    LintingVisitor(getDefaultEngineOptions(),ctx).visitCreateViewStatement(viewStmt,null);
    if (ctx.errors.isNotEmpty){
      throw ViewProcessorError(classElement).lintErrorFromSqlparser(ctx.errors.first);
    }

    // let sqlparser convert the parser node into a sqlparser view
    final view = const SchemaFromCreateTable(
      moorExtensions: false
    ).readView(ctx,viewStmt);

    // check for type mismatches
    //TODO carve out to generic type mismatch checker
    for(int i=0;i<fields.length;++i){
      final resolvedColumnType = view.resolvedColumns[i].type;

      //be strict here, but could be too strict.
      if (resolvedColumnType.type == BasicType.nullType && !fields[i].isNullable){
        throw ViewProcessorError(classElement).nullableMismatch(fields[i].columnName, fields[i].name);
      }

      if (resolvedColumnType.type != BasicType.nullType) {
        if (ToTableColumn._toBasicType(fields[i].sqlType) != resolvedColumnType){
          throw ViewProcessorError(classElement).typeMismatch(fields[i], resolvedColumnType);
        }
        if (resolvedColumnType.nullable && !fields[i].isNullable){
          throw ViewProcessorError(classElement).nullableMismatch2(fields[i], resolvedColumnType);
        }
      }
    }
    return view;
  }
}