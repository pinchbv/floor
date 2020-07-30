import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/embedded.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process entity', () async {
    final classElement = await createClassElement('''
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
    final embeddeds = <Embedded>[];
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = Entity(
      classElement,
      name,
      fields,
      embeddeds,
      primaryKey,
      foreignKeys,
      indices,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process entity with compound primary key', () async {
    final classElement = await createClassElement('''
      @Entity(primaryKeys: ['id', 'name'])
      class Person {
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
    const embeddeds = <Embedded>[];
    final primaryKey = PrimaryKey(fields, false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = Entity(
      classElement,
      name,
      fields,
      embeddeds,
      primaryKey,
      foreignKeys,
      indices,
      constructor,
    );
    expect(actual, equals(expected));
  });

  group('foreign keys', () {
    test('foreign key holds correct values', () async {
      final classElements = await _createClassElements('''
        @entity
        class Person {
          @primaryKey
          final int id;
          
          final String name;
        
          Person(this.id, this.name);
        }
        
        @Entity(
          foreignKeys: [
            ForeignKey(
              childColumns: ['owner_id'],
              parentColumns: ['id'],
              entity: Person,
              onUpdate: ForeignKeyAction.cascade
              onDelete: ForeignKeyAction.setNull,
            )
          ],
        )
        class Dog {
          @primaryKey
          final int id;
        
          final String name;
        
          @ColumnInfo(name: 'owner_id')
          final int ownerId;
        
          Dog(this.id, this.name, this.ownerId);
        }
    ''');

      final actual = EntityProcessor(classElements[1]).process().foreignKeys[0];

      final expected = ForeignKey(
        'Person',
        ['id'],
        ['owner_id'],
        'CASCADE',
        'SET NULL',
      );
      expect(actual, equals(expected));
    });
  });
}

Future<List<ClassElement>> _createClassElements(final String classes) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $classes
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.toList();
}
