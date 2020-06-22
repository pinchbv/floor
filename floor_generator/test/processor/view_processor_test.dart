import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  //TODO new tests for validator:
  // - use wrong column reference to test validation
  // - use wrong syntax reference to test parser
  // - use wrong types 1,2,3
  // - use variables
  // - no select query
  // - check converter by parallel construction
  test('Process view', () async {
    final classElement = await createClassElement('''
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

  test('Process view with mutliline query', () async {
    final classElement = await createClassElement("""
      @DatabaseView('''
        SELECT * 
        from otherentity
      ''')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    """);

    final actual = ViewProcessor(classElement).process().query;

    const expected = '''
        SELECT * 
        from otherentity
      ''';
    expect(actual, equals(expected));
  });

  test('Process view with concatenated string query', () async {
    final classElement = await createClassElement('''
      @DatabaseView('SELECT * ' 
          'from otherentity')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = ViewProcessor(classElement).process().query;

    const expected = 'SELECT * from otherentity';
    expect(actual, equals(expected));
  });

  test('Process view with dedicated name', () async {
    final classElement = await createClassElement('''
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
}
