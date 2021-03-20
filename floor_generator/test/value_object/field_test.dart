import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  final mockFieldElement = MockFieldElement();

  test('Get database definition with auto generate primary key', () {
    const autoGenerate = true;
    final field = Field(
      mockFieldElement,
      'field1Name',
      'field1ColumnName',
      false,
      SqlType.integer,
      null,
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
      SqlType.text,
      null,
    );

    final actual = field.getDatabaseDefinition(autoGenerate);

    final expected = '`${field.columnName}` ${field.sqlType}';
    expect(actual, equals(expected));
  });
}
