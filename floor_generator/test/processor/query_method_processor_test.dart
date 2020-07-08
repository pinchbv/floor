import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_method_processor.dart';
import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

// TODO update tests (list incomplete)
// todo put parsing into query processor test
// todo add return type checking test, e.g. delete query with wrong return types
// TODO test multiple queries separated by semicolon

void main() {
  List<Entity> entities;
  List<View> views;
  AnalyzerEngine engine;

  setUpAll(() async {
    engine = AnalyzerEngine();

    entities = await getEntities(engine);

    views = await getViews(engine);
  });
  test('create query method', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();      
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [...entities, ...views], engine)
            .process();

    expect(
      actual,
      equals(
        QueryMethod(
          methodElement,
          'findAllPersons',
          QueryProcessor(methodElement, 'SELECT * FROM Person', engine)
              .process(),
          QueryMethodReturnType(
              await getDartTypeWithPerson('Future<List<Person>>'))
            ..queryable = entities.first,
          [],
        ),
      ),
    );
  });

  test('create query method for a view', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM name')
      Future<List<Name>> findAllNames();      
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [...entities, ...views], engine)
            .process();

    expect(
      actual,
      equals(
        QueryMethod(
          methodElement,
          'findAllNames',
          QueryProcessor(methodElement, 'SELECT * FROM name', engine).process(),
          QueryMethodReturnType(await getDartTypeWithName('Future<List<Name>>'))
            ..queryable = views.first,
          [],
        ),
      ),
    );
  });
// TODO fix this test which got moved from the writer test
/*  test('query with unsupported type throws', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person> findById(Person person);
    ''');

    final actual = () => QueryMethodWriter(queryMethod).write();

    expect(actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
  });*/
  group('query parsing', () {
    test('parse query', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPerson(int id);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process()
              .query
              .sql;

      expect(actual, equals('SELECT * FROM Person WHERE id = ?1'));
    });

    test('parse multiline query', () async {
      final methodElement = await _createQueryMethodElement("""
        @Query('''
          SELECT * FROM person
          WHERE id = :id AND name = :name
        ''')
        Future<Person> findPersonByIdAndName(int id, String name);
      """);

      final actual =
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process()
              .query
              .sql;

      expect(
        actual,
        equals(
            '          SELECT * FROM person\n          WHERE id = ?1 AND name = ?2\n        '),
      );
    });

    test('parse concatenated string query', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM person '
            'WHERE id = :id AND name = :name')
        Future<Person> findPersonByIdAndName(int id, String name);    
      ''');

      final actual =
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process()
              .query
              .sql;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ?1 AND name = ?2'),
      );
    });

    test('Parse IN clause', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query("update Person set name = '1' where id in (:ids)")
      Future<void> setRated(List<int> ids);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], engine).process().query.sql;

      expect(
        actual,
        equals(r'''update Person set name = '1' where id in (:varlist)'''),
      );
    });

    test('Parse query with multiple IN clauses', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query("update Person set name = '1' where id in (:ids) and name in (:bar)")
      Future<void> setRated(List<int> ids, List<String> bar);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], engine).process().query.sql;

      expect(
        actual,
        equals(
          r'''update Person set name = '1' where id in (:varlist) '''
          r'and name in (:varlist)',
        ),
      );
    });

    test('Parse query with IN clause and other parameter', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query("update Person set name = '1' where id in (:ids) AND name = :bar")
      Future<void> setRated(List<int> ids, int bar);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], engine).process().query.sql;

      expect(
        actual,
        equals(
          "update Person set name = '1' where id in (:varlist) "
          'AND name = ?1',
        ),
      );
    });

    test('Parse query with LIKE operator', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE name LIKE :name')
      Future<List<Person>> findPersonsWithNamesLike(String name);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process()
              .query
              .sql;

      expect(actual, equals('SELECT * FROM Person WHERE name LIKE ?1'));
    });

    test('Parse query with commas', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT :table, :otherTable')
      Future<void> findPersonsWithNamesLike(String table, String otherTable);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process()
              .query
              .sql;

      expect(actual, equals('SELECT ?1, ?2'));
    });
  });

  group('errors', () {
    test('exception when method does not return future', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      List<Person> findAllPersons();
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process();

      final error =
          QueryMethodProcessorError(methodElement).doesNotReturnFutureNorStream;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query is empty string', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('')
      Future<List<Person>> findAllPersons();
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process();

      final error = QueryMethodProcessorError(methodElement).noQueryDefined;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query is null', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query()
      Future<List<Person>> findAllPersons();
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process();

      final error = QueryMethodProcessorError(methodElement).noQueryDefined;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
      Future<Person> findPersonByIdAndName(int id);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process();

      //maybe mock ColonNamedVariable, or else the following line will not match.
      // final error = QueryAnalyzerError(methodElement).queryParameterMissingInMethod(ColonNamedVariable(ColonVariableToken(null,':name')));
      expect(
          actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPersonByIdAndName(int id, String name);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], engine)
              .process();
      expect(
          actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
    });
  });
}

Future<MethodElement> _createQueryMethodElement(
  final String method,
) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
        $method
      }
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
      
      @DatabaseView("SELECT DISTINCT(name) AS name from person")
      class Name {
        final String name;
      
        Name(this.name);
      }
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first.methods.first;
}
