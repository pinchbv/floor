import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_method_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  List<Entity> entities;
  List<View> views;
  AnalyzerEngine engine;

  setUpAll(() async {
    engine = AnalyzerEngine();

    entities = await _getEntities();
    entities.forEach(engine.registerEntity);

    views = await _getViews();
    views.forEach(engine.checkAndRegisterView);
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
          engine.analyzeQuery('SELECT * FROM Person', methodElement),
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
          engine.analyzeQuery('SELECT * FROM name', methodElement),
          QueryMethodReturnType(await getDartTypeWithName('Future<List<Name>>'))
            ..queryable = views.first,
          [],
        ),
      ),
    );
  });

  group('query parsing', () {
    test('parse query', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPerson(int id);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(actual, equals('SELECT * FROM Person WHERE id = ?1'));
    },
        skip:
            "No Entities are known during the QueryMethodProcessor, can't test until they are.");

    test('parse multiline query', () async {
      final methodElement = await _createQueryMethodElement("""
        @Query('''
          SELECT * FROM person
          WHERE id = :id AND custom_name = :name
        ''')
        Future<Person> findPersonByIdAndName(int id, String name);
      """);

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ?1 AND custom_name = ?2'),
      );
    },
        skip:
            "No Entities are known during the QueryMethodProcessor, can't test until they are.");

    test('parse concatenated string query', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM person '
            'WHERE id = :id AND custom_name = :name')
        Future<Person> findPersonByIdAndName(int id, String name);    
      ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ?1 AND custom_name = ?2'),
      );
    },
        skip:
            "No Entities are known during the QueryMethodProcessor, can't test until they are.");

    test('Parse IN clause', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids)')
      Future<void> setRated(List<int> ids);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(
        actual,
        equals(r'update sports set rated = 1 where id in (:varlist)'),
      );
    });

    test('Parse query with multiple IN clauses', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) and foo in (:bar)')
      Future<void> setRated(List<int> ids, List<int> bar);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(
        actual,
        equals(
          r'update sports set rated = 1 where id in (:varlist) '
          r'and foo in (:varlist)',
        ),
      );
    });

    test('Parse query with IN clause and other parameter', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) AND foo = :bar')
      Future<void> setRated(List<int> ids, int bar);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(
        actual,
        equals(
          'update sports set rated = 1 where id in (:varlist) '
          'AND foo = ?2',
        ),
      );
    });

    test('Parse query with LIKE operator', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Persons WHERE name LIKE :name')
      Future<List<Person>> findPersonsWithNamesLike(String name);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(actual, equals('SELECT * FROM Persons WHERE name LIKE ?'));
    },
        skip:
            "No Entities are known during the QueryMethodProcessor, can't test until they are.");

    test('Parse query with commas', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM :table, :otherTable')
      Future<List<Person>> findPersonsWithNamesLike(String table, String otherTable);
    ''');

      final actual = QueryMethodProcessor(methodElement, [], engine)
          .process()
          .sqliteContext
          .processedQuery;

      expect(actual, equals('SELECT * FROM ?1, ?2'));
    },
        skip:
            "No Entities are known during the QueryMethodProcessor, can't test until they are.");
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

Future<List<Entity>> _getEntities() async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();
}

Future<List<View>> _getViews() async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @DatabaseView("SELECT DISTINCT(name) AS name from person")
      class Name {
        final String name;
      
        Name(this.name);
      }
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes
      .where((classElement) =>
          classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement).process())
      .toList();
}
