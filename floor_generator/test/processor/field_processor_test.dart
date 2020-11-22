// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../dart_type.dart';

void main() {
  test('Process field', () async {
    final fieldElement = await _generateFieldElement('''
      final int id;
    ''');

    final actual = FieldProcessor(fieldElement, null).process();

    const name = 'id';
    const columnName = 'id';
    const isNullable = false;
    const sqlType = SqlType.integer;
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      null,
    );
    expect(actual, equals(expected));
  });

  test('Process field with nullable Dart type', () async {
    final fieldElement = await _generateFieldElement('''
      final int? id;
    ''');

    final actual = FieldProcessor(fieldElement, null).process();

    const name = 'id';
    const columnName = 'id';
    const isNullable = true;
    const sqlType = SqlType.integer;
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      null,
    );
    expect(actual, equals(expected));
  });

  test('Process Uint8List field', () async {
    final fieldElement = await _generateFieldElement('''
      @ColumnInfo(name: 'data', nullable: false)
      final Uint8List bytes;
    ''');

    final actual = FieldProcessor(fieldElement, null).process();

    const name = 'bytes';
    const columnName = 'data';
    const isNullable = false;
    const sqlType = SqlType.blob;
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      null,
    );
    expect(actual, equals(expected));
  });

  test('Process field with external type converter', () async {
    final typeConverter = TypeConverter(
      'TypeConverter',
      await dateTimeDartType,
      await intDartType,
      TypeConverterScope.dao,
    );
    final fieldElement = await _generateFieldElement('''
      final DateTime dateTime;
    ''');

    final actual = FieldProcessor(fieldElement, typeConverter).process();

    const name = 'dateTime';
    const columnName = 'dateTime';
    const isNullable = false;
    const sqlType = SqlType.integer; // converted from DateTime
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      typeConverter,
    );
    expect(actual, equals(expected));
  });

  test('Process field with local type converter', () async {
    final fieldElement = await _generateFieldElement('''
      @TypeConverters([DateTimeConverter])
      final DateTime dateTime;
    ''');

    final actual = FieldProcessor(fieldElement, null).process();

    const name = 'dateTime';
    const columnName = 'dateTime';
    const isNullable = false;
    const sqlType = SqlType.integer; // converted from DateTime
    final typeConverter = TypeConverter(
      'DateTimeConverter',
      await dateTimeDartType,
      await intDartType,
      TypeConverterScope.field,
    );
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      typeConverter,
    );
    expect(actual, equals(expected));
  });

  test('Process field and prefer local type converter over external', () async {
    final externalTypeConverter = TypeConverter(
      'ExternalConverter',
      await dateTimeDartType,
      await intDartType,
      TypeConverterScope.dao,
    );
    final fieldElement = await _generateFieldElement('''
      @TypeConverters([DateTimeConverter])
      final DateTime dateTime;
    ''');

    final actual =
        FieldProcessor(fieldElement, externalTypeConverter).process();

    const name = 'dateTime';
    const columnName = 'dateTime';
    const isNullable = false;
    const sqlType = SqlType.integer; // converted from DateTime
    final typeConverter = TypeConverter(
      'DateTimeConverter',
      await dateTimeDartType,
      await intDartType,
      TypeConverterScope.field,
    );
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
      typeConverter,
    );
    expect(actual, equals(expected));
  });
}

Future<FieldElement> _generateFieldElement(final String field) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      import 'dart:typed_data';
      
      class Foo {
        $field
      }
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
      
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
      }
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first.fields.first;
}
