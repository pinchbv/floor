import 'package:floor_generator/processor/query_processor.dart';
import 'package:test/test.dart';

void main() {
  group('variable detection', () {
    testVarFind('empty_query1', '', []);
    testVarFind('empty_query2', '  ', []);
    testVarFind('empty_query3', '\n', []);

    testVarFind('no_variable1', ':', []);
    testVarFind('no_variable2', ': foo', []);
    testVarFind('no_variable3', ' in (:)', []);
    testVarFind('no_variable4', '(:)', []);
    testVarFind('no_variable5', 'SELECT foo FROM bar WHERE id="more"', []);

    testVarFind('simple_variable1', ':f', [VariableToken(':f', 0, false)]);
    testVarFind('simple_variable2', 'SELECT * FROM bar WHERE :id="more"',
        [VariableToken(':id', 24, false)]);
    testVarFind('simple_variable3', 'SELECT * FROM bar WHERE x in :id',
        [VariableToken(':id', 29, false)]);
    testVarFind('simple_variable4', ':id-:id2',
        [VariableToken(':id', 0, false), VariableToken(':id2', 4, false)]);
    testVarFind('simple_variable5', ':id-:id2+:id', [
      VariableToken(':id', 0, false),
      VariableToken(':id2', 4, false),
      VariableToken(':id', 9, false)
    ]);
    testVarFind('simple_variable6', ':id-: id2+:id',
        [VariableToken(':id', 0, false), VariableToken(':id', 10, false)]);
    testVarFind('simple_variable7', 'SELECT * FROM bar WHERE xin (:id)',
        [VariableToken(':id', 29, false)]);

    testVarFind(
        'list_variable1', 'x in(:foo)', [VariableToken(':foo', 5, true)]);
    testVarFind(
        'list_variable2', 'x in (:foo)', [VariableToken(':foo', 6, true)]);
    testVarFind(
        'list_variable3', 'x IN   (:foo)', [VariableToken(':foo', 8, true)]);
    testVarFind(
        'list_variable4', 'x In (:fo2o)', [VariableToken(':fo2o', 6, true)]);
    testVarFind('list_variable5', ':2x iN (:fo2o)',
        [VariableToken(':2x', 0, false), VariableToken(':fo2o', 8, true)]);
  });
}

void testVarFind(
    String testName, String query, List<VariableToken> expectedOutput) {
  test(testName, () {
    expect(
      findVariables(query),
      orderedEquals(expectedOutput),
    );
  });
}
