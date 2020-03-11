import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:floor_generator/value_object/field.dart';
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
    SqlType.INTEGER,
  );
  final nullableField = Field(
    mockFieldElement,
    'field2Name',
    'field2ColumnName',
    true,
    SqlType.TEXT,
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

  group('statement', () {
    test('Create view statement with simple query', () {
      final view = View(
        mockClassElement,
        'entityName',
        allFields,
        'select * from x',
        '',
      );

      final actual = view.getCreateViewStatement();

      final expected =
          'CREATE VIEW IF NOT EXISTS `${view.name}` AS ${view.query}';
      expect(actual, equals(expected));
    });
  });

  group('Value mapping', () {
    final view = View(
      mockClassElement,
      'entityName',
      [nullableField],
      'select * from x',
      '',
    );
    const fieldElementDisplayName = 'foo';

    setUp(() {
      when(mockFieldElement.displayName).thenReturn(fieldElementDisplayName);
      when(mockFieldElement.type).thenReturn(mockDartType);
    });

    test('Get value mapping', () {
      when(mockDartType.isDartCoreBool).thenReturn(false);

      final actual = view.getValueMapping();

      final expected = '<String, dynamic>{'
          "'${nullableField.columnName}': item.$fieldElementDisplayName"
          '}';
      expect(actual, equals(expected));
    });

    test('Get boolean value mapping', () {
      when(mockDartType.isDartCoreBool).thenReturn(true);

      final actual = view.getValueMapping();

      final expected = '<String, dynamic>{'
          "'${nullableField.columnName}': item.$fieldElementDisplayName ? 1 : 0"
          '}';
      expect(actual, equals(expected));
    });
  });
}
