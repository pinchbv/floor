import 'package:flat_annotation/flat_annotation.dart' as annotations;
import 'package:flat_generator/misc/constants.dart';
import 'package:flat_generator/misc/extension/foreign_key_action_extension.dart';
import 'package:flat_generator/value_object/embedded.dart';
import 'package:flat_generator/value_object/entity.dart';
import 'package:flat_generator/value_object/field.dart';
import 'package:flat_generator/value_object/foreign_key.dart';
import 'package:flat_generator/value_object/fts.dart';
import 'package:flat_generator/value_object/primary_key.dart';
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
  final embeddedField = Field(
    fakeFieldElement,
    'embeddedField1Name',
    'embeddedField1ColumnName',
    false,
    SqlType.integer,
    null,
  );
  final embeddedField2 = Field(
    fakeFieldElement,
    'embeddedField2Name',
    'embeddedField2ColumnName',
    false,
    SqlType.integer,
    null,
  );
  final embeddedField3 = Field(
    fakeFieldElement,
    'embeddedField3Name',
    'embeddedField3ColumnName',
    false,
    SqlType.integer,
    null,
  );
  final nullableEmbeddedField = Field(
    fakeFieldElement,
    'embeddedField4Name',
    'embeddedField4ColumnName',
    true,
    SqlType.text,
    null,
  );
  final nullableEmbeddedField2 = Field(
    fakeFieldElement,
    'embeddedField5Name',
    'embeddedField5ColumnName',
    true,
    SqlType.text,
    null,
  );
  final embedded = Embedded(
    fakeFieldElement,
    'embedded1Name',
    [embeddedField, nullableEmbeddedField],
    [],
    false,
  );
  final embedded2 = Embedded(
    fakeFieldElement,
    'embedded2Name',
    [embeddedField3],
    [],
    false,
  );
  final embedded3 = Embedded(
    fakeFieldElement,
    'embedded3Name',
    [embeddedField2, nullableEmbeddedField2],
    [embedded2],
    true,
  );
  final allFields = [field, nullableField];
  final allEmbedded = [embedded, embedded3];

  group('Primary key', () {
    test('Create table statement with single primary key auto increment', () {
      final primaryKey = PrimaryKey([field], true);
      final entity = Entity(
        fakeClassElement,
        'entityName',
        allFields,
        [],
        primaryKey,
        [],
        [],
        false,
        '',
        '',
        null,
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
        fakeClassElement,
        'entityName',
        allFields,
        [],
        primaryKey,
        [],
        [],
        false,
        '',
        '',
        null,
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
        fakeClassElement,
        'entityName',
        allFields,
        [],
        primaryKey,
        [],
        [],
        false,
        '',
        '',
        null,
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
        annotations.ForeignKeyAction.cascade,
        annotations.ForeignKeyAction.noAction,
      );
      final primaryKey = PrimaryKey([nullableField], true);
      final entity = Entity(
        fakeClassElement,
        'entityName',
        [nullableField],
        [],
        primaryKey,
        [foreignKey],
        [],
        false,
        '',
        '',
        null,
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
          '(`${nullableField.columnName}` ${nullableField.sqlType} PRIMARY KEY AUTOINCREMENT, '
          'FOREIGN KEY (`${foreignKey.childColumns[0]}`) '
          'REFERENCES `${foreignKey.parentName}` '
          '(`${foreignKey.parentColumns[0]}`) '
          'ON UPDATE ${foreignKey.onUpdate.toSql()} '
          'ON DELETE ${foreignKey.onDelete.toSql()}'
          ')';
      expect(actual, equals(expected));
    });
  });

  group('Fts key', () {
    test('Create table statement with fts key', () {
      final fts = Fts4(
        'porter',
        [],
      );
      final primaryKey = PrimaryKey([], true);
      final entity = Entity(
        fakeClassElement,
        'entityName',
        [nullableField],
        [],
        primaryKey,
        [],
        [],
        false,
        '',
        '',
        fts,
      );

      final actual = entity.getCreateTableStatement();

      final expected = 'CREATE VIRTUAL TABLE IF NOT EXISTS `${entity.name}` '
          'USING fts4'
          '(`${nullableField.columnName}` ${nullableField.sqlType}, '
          'tokenize=porter '
          ')';
      expect(actual, equals(expected));
    });
  });

  test('Create table statement with "WITHOUT ROWID"', () {
    final primaryKey = PrimaryKey([field], false);
    final entity = Entity(
      fakeClassElement,
      'entityName',
      allFields,
      [],
      primaryKey,
      [],
      [],
      true,
      '',
      '',
      null,
    );

    final actual = entity.getCreateTableStatement();

    final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
        '(`${field.columnName}` ${field.sqlType} NOT NULL, '
        '`${nullableField.columnName}` ${nullableField.sqlType}, '
        'PRIMARY KEY (`${field.columnName}`)'
        ') WITHOUT ROWID';
    expect(actual, equals(expected));
  });

  test('Create table statement with embedded object', () {
    final primaryKey = PrimaryKey([field], true);
    final entity = Entity(
      fakeClassElement,
      'entityName',
      allFields,
      allEmbedded,
      primaryKey,
      [],
      [],
      false,
      '',
      '',
      null,
    );

    final actual = entity.getCreateTableStatement();

    final expected = 'CREATE TABLE IF NOT EXISTS `${entity.name}` '
        '(`${field.columnName}` ${field.sqlType} PRIMARY KEY AUTOINCREMENT NOT NULL, '
        '`${nullableField.columnName}` ${nullableField.sqlType}, '
        '`${embedded.fields[0].columnName}` ${embedded.fields[0].sqlType} NOT NULL, '
        '`${embedded.fields[1].columnName}` ${embedded.fields[1].sqlType}, '
        '`${embedded3.fields[0].columnName}` ${embedded3.fields[0].sqlType}, '
        '`${embedded3.fields[1].columnName}` ${embedded3.fields[1].sqlType}, '
        '`${embedded2.fields[0].columnName}` ${embedded2.fields[0].sqlType}'
        ')';
    expect(actual, equals(expected));
  });
}
