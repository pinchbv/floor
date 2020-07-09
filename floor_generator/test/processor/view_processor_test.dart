import 'package:floor_generator/processor/error/type_checker_error.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart' show BasicType;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process view', () async {
    final classElement = await createClassElement('''
      @DatabaseView('SELECT * from Person')
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();

    const name = 'PersonView';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    const query = 'SELECT * from Person';
    const constructor = "PersonView(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process view with multiline query', () async {
    final classElement = await createClassElement("""
      @DatabaseView('''
        SELECT * 
        from Person
      ''', viewName:'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    """);

    final actual =
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process()
            .query;

    const expected = '''
        SELECT * 
        from Person
      ''';
    expect(actual, equals(expected));
  });

  test('Process view with concatenated string query', () async {
    final classElement = await createClassElement('''
      @DatabaseView('SELECT * ' 
          'from Person', viewName: 'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process()
            .query;

    const expected = 'SELECT * from Person';
    expect(actual, equals(expected));
  });

  test('Process view with dedicated name', () async {
    final classElement = await createClassElement('''
      @DatabaseView("SELECT * from Person", viewName: "personview")
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();

    const name = 'personview';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    const query = 'SELECT * from Person';
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

  group('Expecting errors:', () {
    test('Wrong syntax in annotation', () async {
      final classElement = await createClassElement('''
      @DatabaseView('SELECT *, (wrong_column from Person)', viewName: 'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The following error occurred while parsing the SQL-Statement in ',
                  element: classElement)));
    });

    test('Not a SELECT statement', () async {
      final classElement = await createClassElement('''
        @DatabaseView('DELETE FROM Person', viewName: 'personview')
        class Person {
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ViewProcessorError(classElement).missingSelectQuery));
    });

    test('Wrong column reference in annotation', () async {
      final classElement = await createClassElement('''
      @DatabaseView('SELECT *, wrong_column from Person', viewName: 'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The following error occurred while analyzing the SQL-Statement in ',
                  element: classElement)));
    });

    test('Using :variables in annotation', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT *, :var from Person', viewName: 'personview')
        class Person {
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The query should not contain any variable references\n',
                  todo: 'Remove all variables by altering the query.',
                  element: classElement)));
    });

    test('Using ?variables in annotation', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT *, ?2 from Person', viewName: 'personview')
        class Person {
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The query should not contain any variable references\n',
                  todo: 'Remove all variables by altering the query.',
                  element: classElement)));
    });

    test('Column mismatch', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT NULL from Person', viewName: 'personview')
        class Person {
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The following error occurred while comparing the DatabaseView to the SQL-Statement in ',
                  todo: '',
                  element: classElement)));
    });

    test('Column type mismatch: null to non-nullable', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT NULL as id, name from Person', viewName: 'personview')
        class Person {
          
          @ColumnInfo(nullable:false)
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceError(TypeCheckerError(classElement)
              .nullableMismatch(Field(
                  classElement.fields[0], 'id', 'id', false, 'INTEGER'))));
    });

    test('Column type mismatch: int to String', () async {
      //field id from Person Entity is of type int
      final classElement = await createClassElement('''
        @DatabaseView('SELECT id, name from Person', viewName: 'personview')
        class Person {

          final String id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceError(TypeCheckerError(classElement)
              .typeMismatch(
                  Field(classElement.fields[0], 'id', 'id', true, 'TEXT'),
                  BasicType.int)));
    });

    test('Column type mismatch: nullable to non-nullable', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT nullif(id,1) as id, name from Person', viewName: 'personview')
        class Person {
          
          @ColumnInfo(nullable:false)
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsInvalidGenerationSourceError(TypeCheckerError(classElement)
              .nullableMismatch2(Field(
                  classElement.fields[0], 'id', 'id', false, 'INTEGER'))));
    });
  });
}
