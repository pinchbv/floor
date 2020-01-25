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
  test('Process entity', () async {
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
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process entity with compound primary key', () async {
    final classElement = await _createClassElement('''
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
    final primaryKey = PrimaryKey(fields, false);
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
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Ignore hashCode field', () async {
    final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        @override
        int get hashCode => id.hashCode ^ name.hashCode;
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    expect(actual.fields.length, equals(2));
  });

  test('Ignore static field', () async {
    final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    expect(actual.fields.length, equals(2));
  });

  group('Constructors', () {
    test('generate simple constructor', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named argument', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, {this.bar});
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named arguments', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        final String bar;
      
        Person({this.id, this.name, this.bar});
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected =
          "Person(id: row['id'] as int, name: row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional argument', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, [this.bar]);
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional arguments', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        final String bar;
      
        Person([this.id, this.name, this.bar]);
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });
  });

  group('@Ignore', () {
    test('ignore field not present in constructor', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = EntityProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name);

      const expected = 'foo';
      expect(actual, isNot(contains(expected)));
    });

    test('ignore field present in constructor', () async {
      final classElement = await _createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name, [this.foo = 'foo']);
      }
    ''');

      final actual = EntityProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });
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
              onUpdate: ForeignKeyAction.CASCADE
              onDelete: ForeignKeyAction.SET_NULL,
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
