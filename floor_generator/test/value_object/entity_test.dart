import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/primary_key.dart';
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

  group('Primary key', () {
    test('Create table statement with single primary key auto increment', () {
      final primaryKey = PrimaryKey([field], true);
      final entity = Entity(
        mockClassElement,
        'entityName',
        allFields,
        primaryKey,
        [],
        [],
        false,
        '',
        '',
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
          '(`${field.columnName}` ${field.sqlType} PRIMARY KEY AUTOINCREMENT NOT NULL, '
          '`${nullableField.columnName}` ${nullableField.sqlType}'
          ')';
      expect(actual, equals(expected));
    });

    test('Create table statement with single primary key', () {
      final primaryKey = PrimaryKey([field], false);
      final entity = Entity(
        mockClassElement,
        'entityName',
        allFields,
        primaryKey,
        [],
        [],
        false,
        '',
        '',
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
          '(`${field.columnName}` ${field.sqlType} NOT NULL, '
          '`${nullableField.columnName}` ${nullableField.sqlType}, '
          'PRIMARY KEY (`${field.columnName}`)'
          ')';
      expect(actual, equals(expected));
    });

    test('Create table statement with compound primary key', () {
      final primaryKey = PrimaryKey(allFields, false);
      final entity = Entity(
        mockClassElement,
        'entityName',
        allFields,
        primaryKey,
        [],
        [],
        false,
        '',
        '',
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
          '(`${field.columnName}` ${field.sqlType} NOT NULL, '
          '`${nullableField.columnName}` ${nullableField.sqlType}, '
          'PRIMARY KEY (`${field.columnName}`, `${nullableField.columnName}`)'
          ')';
      expect(actual, equals(expected));
    });
  });

  group('Foreign key', () {
    test('Create table statement with foreign key', () {
      final foreignKey = ForeignKey(
        'parentName',
        ['parentColumn'],
        ['childColumn'],
        'foo',
        'bar',
      );
      final primaryKey = PrimaryKey([nullableField], true);
      final entity = Entity(
        mockClassElement,
        'entityName',
        [nullableField],
        primaryKey,
        [foreignKey],
        [],
        false,
        '',
        '',
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
          '(`${nullableField.columnName}` ${nullableField.sqlType} PRIMARY KEY AUTOINCREMENT, '
          'FOREIGN KEY (`${foreignKey.childColumns[0]}`) '
          'REFERENCES `${foreignKey.parentName}` '
          '(`${foreignKey.parentColumns[0]}`) '
          'ON UPDATE ${foreignKey.onUpdate} '
          'ON DELETE ${foreignKey.onDelete}'
          ')';
      expect(actual, equals(expected));
    });
  });

  test('Create table statement with "WITHOUT ROWID"', () {
    final primaryKey = PrimaryKey([field], false);
    final entity = Entity(
      mockClassElement,
      'entityName',
      allFields,
      primaryKey,
      [],
      [],
      true,
      '',
      '',
    );

    final actual = entity.getCreateTableStatement();

    final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
        '(`${field.columnName}` ${field.sqlType} NOT NULL, '
        '`${nullableField.columnName}` ${nullableField.sqlType}, '
        'PRIMARY KEY (`${field.columnName}`)'
        ') WITHOUT ROWID';
    expect(actual, equals(expected));
  });
}
