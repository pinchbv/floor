import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/view.dart';

import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  test('Process view', () async {
    final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = ViewProcessor(classElement).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    const query = 'SELECT * from otherentity';
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process view with dedicated name', () async {
    final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity",viewName: "personview")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = ViewProcessor(classElement).process();

    const name = 'personview';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    const query = 'SELECT * from otherentity';
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Ignore hashCode field', () async {
    final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        @override
        int get hashCode => id.hashCode ^ name.hashCode;
      }
    ''');

    final actual = ViewProcessor(classElement).process();

    expect(actual.fields.length, equals(2));
  });

  test('Ignore static field', () async {
    final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

    final actual = ViewProcessor(classElement).process();

    expect(actual.fields.length, equals(2));
  });

  group('Constructors', () {
    test('generate simple constructor', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named argument', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, {this.bar});
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named arguments', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person({this.id, this.name, this.bar});
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected =
          "Person(id: row['id'] as int, name: row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional argument', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, [this.bar]);
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional arguments', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person([this.id, this.name, this.bar]);
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String)";
      expect(actual, equals(expected));
    });
  });

  group('@Ignore', () {
    test('ignore field not present in constructor', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = ViewProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name);

      const expected = 'foo';
      expect(actual, isNot(contains(expected)));
    });

    test('ignore field present in constructor', () async {
      final classElement = await _createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String foo;
      
        Person(this.id, this.name, [this.foo = 'foo']);
      }
    ''');

      final actual = ViewProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
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
