// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process view', () async {
    final classElement = await createClassElement('''
      @DatabaseView("SELECT * from otherentity")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = ViewProcessor(classElement, {}).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
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

  test('Process view starting with WITH statement', () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery as (SELECT * from otherentity) SELECT subquery.*")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = ViewProcessor(classElement, {}).process();

    const name = 'Person';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    const query =
        'WITH subquery as (SELECT * from otherentity) SELECT subquery.*';
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
  test('Throws when processing view without SELECT', () async {
    final classElement = await createClassElement('''
      @DatabaseView("DELETE all from Person")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = () => ViewProcessor(classElement, {}).process();

    expect(actual, throwsInvalidGenerationSourceError());
  });

  test(
      'Throws when processing view starting with WITH statement without SELECT',
      () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = () => ViewProcessor(classElement, {}).process();

    expect(actual, throwsInvalidGenerationSourceError());
  });

  test(
      'Throws when processing view starting with WITH statement with only one SELECT',
      () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery as (SELECT * from otherentity)")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = () => ViewProcessor(classElement, {}).process();

    expect(actual, throwsInvalidGenerationSourceError());
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

    final actual = ViewProcessor(classElement, {}).process().query;

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

    final actual = ViewProcessor(classElement, {}).process().query;

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

    final actual = ViewProcessor(classElement, {}).process();

    const name = 'personview';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
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
