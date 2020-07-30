import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/error/type_checker_error.dart';
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
// already done: columnCountMismatch Error

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
    // has to exist or DartType(Person) != DartType(Person) because
    // they are from different sources otherwise
    const matchingSourceId = 1234;
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();      
    ''', matchingSourceId);

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
          QueryMethodReturnType(await getDartTypeWithPerson(
              'Future<List<Person>>', matchingSourceId))
            ..queryable = entities.first,
          [],
        ),
      ),
    );
  });

  test('create query method for a view', () async {
    // has to exist or DartType(Name) != DartType(Name) because
    // they are from different sources otherwise
    const matchingSourceId = 1234;
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM name')
      Future<List<Name>> findAllNames();      
    ''', matchingSourceId);

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
          QueryMethodReturnType(
              await getDartTypeWithName('Future<List<Name>>', matchingSourceId))
            ..queryable = views.first,
          [],
        ),
      ),
    );
  });
  group('query parsing - dart syntax', () {
    test('parse simple query', () async {
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
  });

  group('return type checking', () {
    test('parse contains function', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :needle IN (:haystack)')
        Future<bool> contains(List<String> haystack, String needle);''');

      //should not throw errors
      QueryMethodProcessor(methodElement, [], engine).process();
    });
    //TODO more
  });

  group('errors', () {
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

    group('return type', () {
      test('exception when method does not return future', () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('SELECT * FROM Person')
          List<Person> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error = QueryMethodProcessorError(methodElement)
            .doesNotReturnFutureNorStream;
        expect(actual, throwsInvalidGenerationSourceError(error));
      });

      test(
          'exception when method does not return primitive or Queryable or List',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('SELECT * FROM Person')
          Future<Set<Person>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error = QueryMethodProcessorError(methodElement)
            .doesNotReturnQueryableOrPrimitive;
        expect(actual, throwsInvalidGenerationSourceError(error));
      });

      test(
          'exception when method does not return Future<void> when returning void - Stream',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('SELECT * FROM Person')
          Stream<void> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error =
            QueryMethodProcessorError(methodElement).voidReturnCannotBeStream;
        expect(actual, throwsInvalidGenerationSourceError(error));
      });
      test(
          'exception when method does not return Future<void> when returning void - Stream<List>',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('SELECT * FROM Person')
          Stream<List<void>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error =
            QueryMethodProcessorError(methodElement).voidReturnCannotBeList;
        expect(actual, throwsInvalidGenerationSourceError(error));
      });
      test(
          'exception when method does not return Future<void> when returning void - Future<List>',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('SELECT * FROM Person')
          Future<List<void>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error =
            QueryMethodProcessorError(methodElement).voidReturnCannotBeList;
        expect(actual, throwsInvalidGenerationSourceError(error));
      });

      test(
          'exception when method does not return void on empty result - Queryable',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('DELETE FROM Person')
          Future<List<Person>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error = TypeCheckerError(methodElement).columnCountMismatch(2, 0);
        expect(actual, throwsInvalidGenerationSourceError(error));
      });

      test(
          'exception when method does not return void on empty result - primitive return type',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('DELETE FROM Person')
          Future<List<int>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error = TypeCheckerError(methodElement).columnCountShouldBeOne(0);
        expect(actual, throwsInvalidGenerationSourceError(error));
      });

      test(
          'exception when method does not return void on empty result - primitive return type',
          () async {
        final methodElement = await _createQueryMethodElement('''
          @Query('DELETE FROM Person')
          Future<List<int>> findAllPersons();
        ''');

        final actual = () =>
            QueryMethodProcessor(methodElement, [...entities, ...views], engine)
                .process();

        final error = TypeCheckerError(methodElement).columnCountShouldBeOne(0);
        expect(actual, throwsInvalidGenerationSourceError(error));
      });
    });
  });
}

Future<MethodElement> _createQueryMethodElement(final String method,
    [int id]) async {
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
  }, inputId: createAssetId(id));

  return library.classes.first.methods.first;
}
