import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/error/entity_processor_error.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/fts.dart';
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
    const valueMapping = "<String, Object?>{'id': item.id, 'name': item.name}";
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
      null,
    );
    expect(actual, equals(expected));
  });

  test(
      'Process entity with null fields falls back to defaults (should be prevented by non-nullable types)',
      () async {
    final classElement = await createClassElement('''
      @Entity(
      tableName:null,
      foreignKeys:null,
      indices:null,
      primaryKeys:null,
      withoutRowid:null,
      )
      @Fts3()
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
    const valueMapping = "<String, Object?>{'id': item.id, 'name': item.name}";
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
      Fts3(annotations.FtsTokenizer.simple, []),
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
    const valueMapping = "<String, Object?>{'id': item.id, 'name': item.name}";
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
      null,
    );
    expect(actual, equals(expected));
  });

  test('Process entity with index', () async {
    final classElement = await createClassElement('''
      @Entity(indices: [Index(name:'i1', unique: true, value:['id']),Index(unique: false, value:['name', 'id'])])
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
    final primaryKey = PrimaryKey(fields.sublist(0, 1), false);
    const foreignKeys = <ForeignKey>[];
    final indices = [
      Index('i1', 'Person', true, ['id']),
      Index('index_Person_name_id', 'Person', false, ['name', 'id'])
    ];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    const valueMapping = "<String, Object?>{'id': item.id, 'name': item.name}";
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
      null,
    );
    expect(actual, equals(expected));
  });

  test(
      'Process entity with named constructor declarations first, before unnamed ones.',
      () async {
    final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;

        factory Person.from(Person other) {
          return Person(other.id, other.name);
        }
      
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
    const valueMapping = "<String, Object?>{'id': item.id, 'name': item.name}";
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
      null,
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
        annotations.ForeignKeyAction.cascade,
        annotations.ForeignKeyAction.setNull,
      );
      expect(actual, equals(expected));
    });
  });

  group('fts keys', () {
    test('fts key with fts3', () async {
      final classElements = await _createClassElements('''
        
        @entity
        @fts3
        class MailInfo {
          @primaryKey
          @ColumnInfo(name: 'rowid')
          final int id;
        
          final String text;
        
          MailInfo(this.id, this.text);
        }
    ''');

      final actual = EntityProcessor(classElements[0], {}).process().fts;

      final Fts expected = Fts3('simple', []);

      expect(actual, equals(expected));
    });
  });

  group('fts keys', () {
    test('fts key with fts4', () async {
      final classElements = await _createClassElements('''
        
        @entity
        @fts4
        class MailInfo {
          @primaryKey
          @ColumnInfo(name: 'rowid')
          final int id;
        
          final String text;
        
          MailInfo(this.id, this.text);
        }
    ''');

      final actual = EntityProcessor(classElements[0], {}).process().fts;

      final Fts expected = Fts4('simple', []);

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
      "<String, Object?>{'id': item.id, 'name': item.name}",
      null,
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

      const expected = '<String, Object?>{'
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

      const expected = '<String, Object?>{'
          "'id': item.id, "
          "'isSomething': item.isSomething == null ? null : (item.isSomething! ? 1 : 0)"
          '}';
      expect(actual, equals(expected));
    });

    test('Non-nullable enum value mapping', () async {
      final classElement = await createClassElement('''
      
      $characterType
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final CharacterType someType;
      
        Person(this.id, this.someType);
      }
    ''');

      final actual = EntityProcessor(classElement, {}).process().valueMapping;

      const expected = '<String, Object?>{'
          "'id': item.id, "
          "'someType': item.someType.index"
          '}';
      expect(actual, equals(expected));
    });

    test('Nullable enum value mapping', () async {
      final classElement = await createClassElement('''
      
      $characterType
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final CharacterType? someType;
      
        Person(this.id, this.someType);
      }
    ''');

      final actual = EntityProcessor(classElement, {}).process().valueMapping;

      const expected = '<String, Object?>{'
          "'id': item.id, "
          "'someType': item.someType?.index"
          '}';
      expect(actual, equals(expected));
    });
  });

  group('expected errors', () {
    test('missing primary key', () async {
      final classElements = await createClassElement('''
          @entity
          class Person {
            final int id;
            
            final String name;
          
            Person(this.id, this.name);
          }
      ''');

      final processor = EntityProcessor(classElements, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements).missingPrimaryKey));
    });
    test('compound primary key mismatch', () async {
      final classElements = await createClassElement('''
          @Entity(
            primaryKeys:['notAField']
          )
          class Person {
            final int id;
            
            final String name;
          
            Person(this.id, this.name);
          }
      ''');

      final processor = EntityProcessor(classElements, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements).missingPrimaryKey));
    });
    test('missing parent columns', () async {
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
                parentColumns: [],
                entity: Person,
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

      final processor = EntityProcessor(classElements[1], {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements[1]).missingParentColumns));
    });
    test('missing child columns', () async {
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
                childColumns: [],
                parentColumns: ['id'],
                entity: Person,
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

      final processor = EntityProcessor(classElements[1], {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements[1]).missingChildColumns));
    });
    test('foreignKey does not reference entity', () async {
      final classElements = await _createClassElements('''
          final Person = ()=>2;
          
          @Entity(
            foreignKeys: [
              ForeignKey(
                childColumns: ['owner_id'],
                parentColumns: ['id'],
                entity: Entity(),
                onUpdate: ForeignKeyAction.setNull
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

      final processor = EntityProcessor(classElements[0], {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements[0])
                  .foreignKeyDoesNotReferenceEntity));
    }, skip: 'Can not reproduce error case');
    test('foreign key reference does not exist', () async {
      final classElements = await createClassElement('''
          @Entity(
            foreignKeys: [
              ForeignKey(
                childColumns: ['owner_id'],
                parentColumns: ['id'],
                entity: Person,
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

      final processor = EntityProcessor(classElements, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElements).foreignKeyNoEntity));
    });
    test('missing index column name', () async {
      final classElement = await createClassElement('''
          @Entity(
            indices:[Index(value:[])]
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

      final processor = EntityProcessor(classElement, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElement).missingIndexColumnName));
    });
    test('no matching index column', () async {
      final classElement = await createClassElement('''
          @Entity(
            indices:[Index(value:['id', 'notAColumn'])]
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

      final processor = EntityProcessor(classElement, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(EntityProcessorError(classElement)
              .noMatchingColumn('notAColumn')));
    });
    test('auto-increment not usable with `WITHOUT ROWID`', () async {
      final classElement = await createClassElement('''
          @Entity(
            withoutRowid:true
          )
          class Dog {
            @PrimaryKey(autoGenerate:true)
            final int id;
          
            final String name;
          
            @ColumnInfo(name: 'owner_id')
            final int ownerId;
          
            Dog(this.id, this.name, this.ownerId);
          }
      ''');

      final processor = EntityProcessor(classElement, {});
      expect(
          processor.process,
          throwsInvalidGenerationSourceError(
              EntityProcessorError(classElement).autoIncrementInWithoutRowid));
    });

    test('missing unnamed constructor.', () async {
      final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;

        factory Person.from(Person other) {
          return Person(other.id, other.name);
        }
      }
    ''');

      final actual = EntityProcessor(classElement, {});

      expect(
        actual.process,
        throwsInvalidGenerationSourceError(
          QueryableProcessorError(classElement).missingUnnamedConstructor,
        ),
      );
    });
  });
}

Future<List<ClassElement>> _createClassElements(final String classes) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $classes
      ''', (resolver) async {
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  return library.classes.toList();
}
