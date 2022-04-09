import 'package:flat_generator/misc/constants.dart';
import 'package:flat_generator/value_object/field.dart';
import 'package:flat_generator/value_object/view.dart';
import 'package:test/test.dart';

import '../fakes.dart';

void main() {
  final fakeClassElement = FakeClassElement();
  final fakeFieldElement = FakeFieldElement();

  final field = Field(
    fakeFieldElement,
    'field1Name',
    'field1ColumnName',
    false,
    SqlType.integer,
    null,
  );
  final nullableField = Field(
    fakeFieldElement,
    'field2Name',
    'field2ColumnName',
    true,
    SqlType.text,
    null,
  );
  final allFields = [field, nullableField];

  test('Create view statement with simple query', () {
    final view = View(
      fakeClassElement,
      'entityName',
      allFields,
      [],
      'SELECT * FROM x',
      '',
    );

    final actual = view.getCreateViewStatement();

    final expected =
        'CREATE VIEW IF NOT EXISTS `${view.name}` AS ${view.query}';
    expect(actual, equals(expected));
  });
}
