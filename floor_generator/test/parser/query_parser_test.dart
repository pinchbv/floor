import 'package:sqlparser/sqlparser.dart';

import 'package:test/test.dart';


void main(){
  test('queryparsertest', () async {
    final id = TableColumn('id', const ResolvedType(type: BasicType.int));
    final content = TableColumn('content', const ResolvedType(type: BasicType.text));
    final demoTable = Table(
      name: 'demo',
      resolvedColumns: [id, content],
    );
    final engine = SqlEngine()..registerTable(demoTable);

    final context =
    engine.analyze('SELECT id, d.content, *, 3 + 4 FROM demo AS d');

    final select = context.root as SelectStatement;
    final resolvedColumns = select.resolvedColumns;
    

    resolvedColumns.map((c) => c.name); // id, content, id, content, 3 + 4
    resolvedColumns.map((c) => context.typeOf(c).type.type); // int, text, int, text, int, int

    final result = engine.parse('''
  SELECT f.* FROM frameworks f
    INNER JOIN uses_language ul ON ul.framework = f.id
    INNER JOIN languages l ON l.id = ul.language
  WHERE l.name = 'Dart'
  ORDER BY f.name ASC, f.popularity DESC
  LIMIT 5 OFFSET 5 * 3
    ''');
    print('Das hier ist die zweite Query:');
    print(result.rootNode.runtimeType);


    const queryParamTest= 'SELECT ?2, ?4, ? , ?, ?, ?5, ?1, ?3';
    final analyzed=engine.analyze(queryParamTest);
    VariableVisitor().visitBaseSelectStatement(analyzed.root, null);

  });
}

class VariableVisitor extends RecursiveVisitor<void,void>{
  @override
  void visitNumberedVariable(NumberedVariable e, void _s) {
    print('variable $e has index ${e.resolvedIndex}');

    return super.visitNumberedVariable(e, _s);
  }
}


//TODO: list parameters out-of-order with normal parameters in-between,
// double-use, strings containing `:abc`, erroring out on `?` vars
