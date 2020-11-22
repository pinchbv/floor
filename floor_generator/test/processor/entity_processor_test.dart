// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
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

    final actual = EntityProcessor(classElement, {}).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    const valueMapping = "<String, dynamic>{'id': item.id, 'name': item.name}";
    final expected = Entity(
      classElement,
      name,
      fields,
      primaryKey,
      foreignKeys,
      indices,
      false,
      constructor,
      valueMapping,
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

    final actual = EntityProcessor(classElement, {}).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    final primaryKey = PrimaryKey(fields, false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    const valueMapping = "<String, dynamic>{'id': item.id, 'name': item.name}";
    final expected = Entity(
      classElement,
      name,
      fields,
      primaryKey,
      foreignKeys,
      indices,
      false,
      constructor,
      valueMapping,
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

      final actual =
          EntityProcessor(classElements[1], {}).process().foreignKeys[0];

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

  test('Process entity with "WITHOUT ROWID"', () async {
    final classElement = await createClassElement('''
      @Entity(withoutRowid: true)
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = EntityProcessor(classElement, {}).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = Entity(
      classElement,
      name,
      fields,
      primaryKey,
      foreignKeys,
      indices,
      true,
      constructor,
      "<String, dynamic>{'id': item.id, 'name': item.name}",
    );
    expect(actual, equals(expected));
  });

  group('Value mapping', () {
    test('Non-nullable boolean value mapping', () async {
      final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final bool isSomething;
      
        Person(this.id, this.isSomething);
      }
    ''');

      final actual = EntityProcessor(classElement, {}).process().valueMapping;

      const expected = '<String, dynamic>{'
          "'id': item.id, "
          "'isSomething': item.isSomething ? 1 : 0"
          '}';
      expect(actual, equals(expected));
    });

    test('Nullable boolean value mapping', () async {
      final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final bool? isSomething;
      
        Person(this.id, this.isSomething);
      }
    ''');

      final actual = EntityProcessor(classElement, {}).process().valueMapping;

      const expected = '<String, dynamic>{'
          "'id': item.id, "
          "'isSomething': item.isSomething == null ? null : (item.isSomething! ? 1 : 0)"
          '}';
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
