import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';

import 'package:test/test.dart';

import '../test_utils.dart';

class MockQueryable extends Queryable {
  MockQueryable(
      ClassElement classElement, List<Field> fields, String constructor)
      : super(classElement, '', fields, constructor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockQueryable &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^ fields.hashCode ^ constructor.hashCode;
}

class MockProcessor extends QueryableProcessor<MockQueryable> {
  MockProcessor(ClassElement classElement) : super(classElement);

  @override
  MockQueryable process() {
    final fields = getFields();
    return MockQueryable(
      classElement,
      fields,
      getConstructor(fields),
    );
  }
}

void main() {
  test('Process Queryable', () async {
    final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = MockProcessor(classElement).process();

    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = MockQueryable(
      classElement,
      fields,
      constructor,
    );
    expect(actual, equals(expected));
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

      final actual = MockProcessor(classElement).process();

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

      final actual = MockProcessor(classElement).process();

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

      final actual = MockProcessor(classElement)
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

      final actual = MockProcessor(classElement)
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

      final actual = MockProcessor(classElement).process().constructor;

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

      final actual = MockProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: row['bar'] as String)";
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

      final actual = MockProcessor(classElement).process().constructor;

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

      final actual = MockProcessor(classElement).process().constructor;

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

      final actual = MockProcessor(classElement).process().constructor;

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

      final actual = MockProcessor(classElement)
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

      final actual = MockProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });
  });
}
