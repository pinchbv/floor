import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:test/test.dart';

void main() {
  group('variable detection', () {
    _testVarFind('empty_query1', '', []);
    _testVarFind('empty_query2', '  ', []);
    _testVarFind('empty_query3', '\n', []);

    _testVarFind('no_variable1', ':', []);
    _testVarFind('no_variable2', ': foo', []);
    _testVarFind('no_variable3', ' in (:)', []);
    _testVarFind('no_variable4', '(:)', []);
    _testVarFind('no_variable5', 'SELECT foo FROM bar WHERE id="more"', []);

    _testVarFind('simple_variable1', ':f', [VariableToken(':f', 0, ParamType.normal)]);
    _testVarFind('simple_variable2', 'SELECT * FROM bar WHERE :id="more"',
        [VariableToken(':id', 24, ParamType.normal)]);
    _testVarFind('simple_variable3', 'SELECT * FROM bar WHERE x in :id',
        [VariableToken(':id', 29, ParamType.normal)]);
    _testVarFind('simple_variable4', ':id-:id2',
        [VariableToken(':id', 0, ParamType.normal), VariableToken(':id2', 4, ParamType.normal)]);
    _testVarFind('simple_variable5', ':id-:id2+:id', [
      VariableToken(':id', 0, ParamType.normal),
      VariableToken(':id2', 4, ParamType.normal),
      VariableToken(':id', 9, ParamType.normal)
    ]);
    _testVarFind('simple_variable6', ':id-: id2+:id',
        [VariableToken(':id', 0, ParamType.normal), VariableToken(':id', 10, ParamType.normal)]);
    _testVarFind('simple_variable7', 'SELECT * FROM bar WHERE xin (:id)',
        [VariableToken(':id', 29, ParamType.normal)]);

    _testVarFind(
        'list_variable1', 'x in(:foo)', [VariableToken(':foo', 5, ParamType.list)]);
    _testVarFind(
        'list_variable2', 'x in (:foo)', [VariableToken(':foo', 6, ParamType.list)]);
    _testVarFind(
        'list_variable3', 'x IN   (:foo)', [VariableToken(':foo', 8, ParamType.list)]);
    _testVarFind(
        'list_variable4', 'x In (:fo2o)', [VariableToken(':fo2o', 6, ParamType.list)]);
    _testVarFind('list_variable5', ':2x iN (:fo2o)',
        [VariableToken(':2x', 0, ParamType.normal), VariableToken(':fo2o', 8,  ParamType.list)]);
    _testVarFind('custom_var1', ' {sun2}',
        [VariableToken('{sun2}', 1,  ParamType.custom)]);
    _testVarFind('custom_var2', ' {sun2} and {good}',
        [VariableToken('{sun2}', 1,  ParamType.custom), VariableToken('{good}', 12,  ParamType.custom)]);
    _testVarFind('custom_var3', ':2x iN (:fo2o) {ghhgh}',
        [VariableToken(':2x', 0, ParamType.normal), VariableToken(':fo2o', 8,  ParamType.list), VariableToken('{ghhgh}', 15,  ParamType.custom)]);
  });

  group('VariableToken get prop', () {
    test(': prop', () {
      expect(VariableToken(':name', 0,  ParamType.normal).prop, 'name');
    });
    test('{} prop', () {
      expect(VariableToken('{sdf123}', 1, ParamType.custom).prop, 'sdf123');
    });
  });
}

void _testVarFind(
    String testName, String query, List<VariableToken> expectedOutput) {
  test(testName, () {
    expect(
      findVariables(query),
      orderedEquals(expectedOutput),
    );
  });
}
