import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  test('successfully process entity', () async {
    final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    final primaryKey = PrimaryKey(fields.first, false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    const readOnly = false;

    expect(
      actual,
      equals(
        Entity(
          classElement,
          name,
          readOnly,
          fields,
          primaryKey,
          foreignKeys,
          indices,
          constructor,
        ),
      ),
    );
  });
}

Future<ClassElement> _createClassElement(final String clazz) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $clazz
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first;
}
