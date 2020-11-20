// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  final mockClassElement = MockClassElement();
  final mockFieldElement = MockFieldElement();
  final mockDartType = MockDartType();

  final field = Field(
    mockFieldElement,
    'field1Name',
    'field1ColumnName',
    false,
    SqlType.integer,
    null,
  );
  final nullableField = Field(
    mockFieldElement,
    'field2Name',
    'field2ColumnName',
    true,
    SqlType.text,
    null,
  );
  final allFields = [field, nullableField];

  tearDown(() {
    clearInteractions(mockClassElement);
    clearInteractions(mockFieldElement);
    clearInteractions(mockDartType);
    reset(mockClassElement);
    reset(mockFieldElement);
    reset(mockDartType);
  });

  test('Create view statement with simple query', () {
    final view = View(
      mockClassElement,
      'entityName',
      allFields,
      'SELECT * FROM x',
      '',
    );

    final actual = view.getCreateViewStatement();

    final expected =
        'CREATE VIEW IF NOT EXISTS `${view.name}` AS ${view.query}';
    expect(actual, equals(expected));
  });
}
