import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/embedded.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process Queryable', () async {
    final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = TestProcessor(classElement).process();

    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    final embeddeds = <Embedded>[];
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = TestQueryable(
      classElement,
      fields,
      embeddeds,
      constructor,
    );
    expect(actual, equals(expected));
  });

  group('Field inheritance', () {
    test('Inherits fields from abstract parent class', () async {
      final classElement = await createClassElement('''
      class TestEntity extends AbstractEntity {
        final String name;
      
        TestEntity(int id, this.name) : super(id);
      }
      
      abstract class AbstractEntity {
        @primaryKey
        final int id;
      
        AbstractEntity(this.id);
      }           
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from abstract parent class', () async {
      final classElement = await createClassElement('''
        class TestEntity extends AnotherAbstractEntity {
          final String name;
        
          TestEntity(int id, double foo, this.name) : super(id, foo);
        }
        
        abstract class AnotherAbstractEntity extends AbstractEntity {
          final double foo;
        
          AnotherAbstractEntity(int id, this.foo) : super(id);
        }
        
        abstract class AbstractEntity {
          @primaryKey
          final int id;
        
          AbstractEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'foo', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['foo'] as double, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from superclass', () async {
      final classElement = await createClassElement('''
        class TestEntity extends SuperClassEntity {
          final String name;
        
          TestEntity(int id, this.name) : super(id);
        }
        
        class SuperClassEntity {
          @primaryKey
          final int id;
        
          SuperClassEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from superclass', () async {
      final classElement = await createClassElement('''
        class TestEntity implements InterfaceEntity {
          @primaryKey
          @override
          final int id;
          final String name;
        
          TestEntity(this.id, this.name);
        }
        
        class InterfaceEntity {
          final int id;
        
          InterfaceEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Throws when queryable inherits from mixin', () async {
      final classElement = await createClassElement('''
        class TestEntity with TestMixin {
          final int id;
        
          TestEntity(this.id);
        }
        
        class TestMixin {
          String name;
        }      
    ''');

      final actual = () => TestProcessor(classElement).process();

      final error = QueryableProcessorError(classElement).prohibitedMixinUsage;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });
  });

  group('Ignore special fields', () {
    test('Ignore static field', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

      final actual = TestProcessor(classElement).process();

      expect(actual.fields.length, equals(2));
    });

    test('Ignore hashCode field', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        @override
        int get hashCode => id.hashCode ^ name.hashCode;
      }
    ''');

      final actual = TestProcessor(classElement).process();

      expect(actual.fields.length, equals(2));
    });

    test('Ignore getter', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        String get label => '\$id: \$name'
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name)
          .toList();

      expect(actual, equals(['id', 'name']));
    });

    test('Ignore setter', () async {
      final classElement = await createClassElement('''
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        set printwith(String prefix) => print(prefix+name);

        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name)
          .toList();

      expect(actual, equals(['id', 'name']));
    });
  });

  group('Constructors', () {
    test('generate simple constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named argument', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, {this.bar});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with boolean arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        @ColumnInfo(nullable: false)
        final bool bar;
        
        final bool foo
      
        Person(this.id, this.name, {this.bar, this.foo});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: (row['bar'] as int) != 0, foo: row['foo'] == null ? null : (row['foo'] as int) != 0)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person({this.id, this.name, this.bar});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(id: row['id'] as int, name: row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional argument', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, [this.bar]);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person([this.id, this.name, this.bar]);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });
  });

  group('@Ignore', () {
    test('ignore field not present in constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name);

      const expected = 'foo';
      expect(actual, isNot(contains(expected)));
    });

    test('ignore field present in constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name, [this.foo = 'foo']);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String, null)";
      expect(actual, equals(expected));
    });
  });
}

class TestQueryable extends Queryable {
  TestQueryable(
    ClassElement classElement,
    List<Field> fields,
    List<Embedded> embeddeds,
    String constructor,
  ) : super(classElement, '', fields, embeddeds, constructor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestQueryable &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^ fields.hashCode ^ constructor.hashCode;

  @override
  String toString() {
    return 'TestQueryable{classElement: $classElement, name: $name, fields: $fields, constructor: $constructor}';
  }
}

class TestProcessor extends QueryableProcessor<TestQueryable> {
  TestProcessor(ClassElement classElement) : super(classElement);

  @override
  TestQueryable process() {
    final fields = getFields();
    final embeddeds = getEmbeddeds();

    return TestQueryable(
      classElement,
      fields,
      embeddeds,
      getConstructor([...fields, ...embeddeds]),
    );
  }
}
