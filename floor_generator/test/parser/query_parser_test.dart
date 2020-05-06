import 'package:floor_generator/query_analyzer/query_parser.dart';
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

  });
}


/*
final dynamic _initialized=(){print("This Xd class was initialized");}();

class Xd{

  void thatf(){

  }
}


void main() {

  test('Includes methods from abstract parent class', () async {
    final parser=QueryParser("SELECT * FROM STUFF JOIN OTHERSTUFF WHERE x is y group by this having ws=3 order by 2");
    final deps=parser.getDependencies();

//    final parser3=QueryParser("DELETE FROM thattable");
//    final deps3=parser3.getDependencies();
//
//    final parser2=QueryParser("DELETE FROM thattable WHERE :condition");
//    final deps2=parser2.getDependencies();

//    print('$deps2,$deps3');
    expect(deps.length, equals(2));
  });


}*/