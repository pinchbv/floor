import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  final mockFieldElement = MockFieldElement();

  tearDown(() {
    clearInteractions(mockFieldElement);
    reset(mockFieldElement);
  });

  test('Get database definition with auto generate primary key', () {
    const autoGenerate = true;
    final field = Field(
      mockFieldElement,
      'field1Name',
      'field1ColumnName',
      false,
      SqlType.INTEGER,
    );

    final actual = field.getDatabaseDefinition(autoGenerate);

    final expected =
        '`${field.columnName}` ${field.sqlType} PRIMARY KEY AUTOINCREMENT NOT NULL';
    expect(actual, equals(expected));
  });

  test('Get database definition', () {
    const autoGenerate = false;
    final field = Field(
      mockFieldElement,
      'field1Name',
      'field1ColumnName',
      true,
      SqlType.TEXT,
    );

    final actual = field.getDatabaseDefinition(autoGenerate);

    final expected = '`${field.columnName}` ${field.sqlType}';
    expect(actual, equals(expected));
  });

  test('Get database definition with check constraint', () {
    const autoGenerate = false;
    const fieldName = 'fieldName';
    const checkConstraint = '$fieldName > 0 AND $fieldName < 5';
    final field = Field(mockFieldElement, fieldName, 'field1ColumnName', true,
        SqlType.INTEGER, checkConstraint);

    final actual = field.getDatabaseDefinition(autoGenerate);
    final expected =
        '`${field.columnName}` ${field.sqlType} CHECK ($checkConstraint)';
    expect(actual, equals(expected));
  });
}
