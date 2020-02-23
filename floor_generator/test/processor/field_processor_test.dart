import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  test('Process field', () async {
    final fieldElement = await _generateFieldElement('''
      final int id;
    ''');

    final actual = FieldProcessor(fieldElement).process();

    const name = 'id';
    const columnName = 'id';
    const isNullable = true;
    const sqlType = SqlType.INTEGER;
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
    );
    expect(actual, equals(expected));
  });

  test('Process Uint8List field', () async {
    final fieldElement = await _generateFieldElement('''
      @ColumnInfo(name: 'data', nullable: false)
      final Uint8List bytes;
    ''');

    final actual = FieldProcessor(fieldElement).process();

    const name = 'bytes';
    const columnName = 'data';
    const isNullable = false;
    const sqlType = SqlType.BLOB;
    final expected = Field(
      fieldElement,
      name,
      columnName,
      isNullable,
      sqlType,
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
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first.fields.first;
}
