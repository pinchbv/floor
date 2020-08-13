import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart' hide View;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  AnalyzerEngine engine;

  setUpAll(() async {
    engine = AnalyzerEngine();

    await getEntities(engine);

    await getViews(engine);
  });

  test('create simple query object', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();
    ''');

    final actual =
        QueryProcessor(methodElement, 'SELECT * FROM Person', engine).process();

    expect(
      actual,
      equals(Query(
        'SELECT * FROM Person',
        [],
        [
          SqlResultColumn(
              'id',
              const ResolveResult(
                  ResolvedType(type: BasicType.int, nullable: true))),
          SqlResultColumn(
              'name',
              const ResolveResult(
                  ResolvedType(type: BasicType.text, nullable: true))),
        ],
        {'Person'},
        {},
      )),
    );
  });

  test('create query object from insert', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('REPLACE INTO Person DEFAULT VALUES')
      Future<void> insertOrReplaceDefaultPerson();
    ''');

    final actual = QueryProcessor(
            methodElement, 'REPLACE INTO Person DEFAULT VALUES', engine)
        .process();

    expect(
      actual,
      equals(Query(
        'REPLACE INTO Person DEFAULT VALUES',
        [],
        [],
        {'Person'},
        {'Person'},
      )),
    );
  });

  test('create query object from delete', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('DELETE FROM Person WHERE id in (:ids)')
      Future<void> deletePersonWithIds(List<int> ids);
    ''');

    final actual = QueryProcessor(
            methodElement, 'DELETE FROM Person WHERE id in (:ids)', engine)
        .process();

    expect(
      actual,
      equals(Query(
        'DELETE FROM Person WHERE id in (:varlist)',
        [ListParameter(32, 'ids')],
        [],
        {'Person'},
        {'Person'},
      )),
    );
  });

  test('create complex query object from update', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('UPDATE Person SET name = :newName where id in (:ids) and name in (:bar)')
      Future<void> updateNames(List<int> ids, List<String> bar, String newName);
    ''');

    final actual = QueryProcessor(
            methodElement,
            'UPDATE Person SET name = :newName where id in (:ids) and name in (:bar)',
            engine)
        .process();

    expect(
      actual,
      equals(Query(
        'UPDATE Person SET name = ?1 where id in (:varlist) and name in (:varlist)',
        [ListParameter(41, 'ids'), ListParameter(64, 'bar')],
        [],
        {'Person'},
        {'Person'},
      )),
    );
  });

  test('create complex query object from select', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query("SELECT *, name='Jules', length(name), :arg1 as X FROM Name WHERE length(name) in (:lengths)")
      Future<void> findAllPersons(List<int> lengths, Uint8List arg1);
    ''');

    final actual = QueryProcessor(
            methodElement,
            'SELECT *, name=\'Jules\', length(name), :arg1 as X FROM Name WHERE length(name) in (:lengths)',
            engine)
        .process();

    expect(
      actual,
      equals(Query(
        'SELECT *, name=\'Jules\', length(name), ?1 as X FROM Name WHERE length(name) in (:varlist)',
        [ListParameter(79, 'lengths')],
        [
          SqlResultColumn(
              'name',
              const ResolveResult(
                  ResolvedType(type: BasicType.text, nullable: true))),
          SqlResultColumn(
              'name=\'Jules\'',
              const ResolveResult(ResolvedType(
                  type: BasicType.int, nullable: false, hint: IsBoolean()))),
          SqlResultColumn(
              'length(name)',
              const ResolveResult(
                  ResolvedType(type: BasicType.int, nullable: false))),
          SqlResultColumn(
              'X',
              const ResolveResult(
                  ResolvedType(type: BasicType.blob, nullable: true))),
        ],
        {'Person'},
        {},
      )),
    );
  });

  test('create query object without dependencies', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT :needle IN (:haystack)')
      Future<bool> contains(List<String> haystack, String needle);
    ''');

    final actual =
        QueryProcessor(methodElement, 'SELECT :needle IN (:haystack)', engine)
            .process();

    expect(
      actual,
      equals(Query(
        'SELECT ?1 IN (:varlist)',
        [ListParameter(14, 'haystack')],
        [
          SqlResultColumn(
              ':needle IN (:haystack)',
              const ResolveResult(ResolvedType(
                  type: BasicType.int, nullable: false, hint: IsBoolean()))),
        ],
        {},
        {},
      )),
    );
  });

  group('parameter parsing', () {
    test('Parse query with IN clause', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query("update Person set name = '1' where id in (:ids)")
        Future<void> setRated(List<int> ids);
      ''');

      final actual = QueryProcessor(methodElement,
              "update Person set name = '1' where id in (:ids)", engine)
          .process();

      expect(
        actual.listParameters,
        equals([ListParameter(42, 'ids')]),
      );
      expect(actual.sql,
          equals("update Person set name = '1' where id in (:varlist)"));
    });

    test('Parse query with multiple IN clauses', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query("update Person set name = '1' where id in (:ids) and name in (:bar)")
        Future<void> setRated(List<int> ids, List<String> bar);
      ''');

      final actual = QueryProcessor(
              methodElement,
              "update Person set name = '1' where id in (:ids) and name in (:bar)",
              engine)
          .process();

      expect(
        actual.sql,
        equals(
          "update Person set name = '1' where id in (:varlist) "
          'and name in (:varlist)',
        ),
      );
      expect(
        actual.listParameters,
        equals([ListParameter(42, 'ids'), ListParameter(65, 'bar')]),
      );
    });

    test('Parse query with IN clause and other parameter', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query("update Person set name = '1' where id in (:ids) AND name = :bar")
        Future<void> setRated(List<int> ids, int bar);
      ''');

      final actual = QueryProcessor(
              methodElement,
              "update Person set name = '1' where id in (:ids) AND name = :bar",
              engine)
          .process();

      expect(
        actual.sql,
        equals(
          "update Person set name = '1' where id in (:varlist) AND name = ?1",
        ),
      );
      expect(
        actual.listParameters,
        equals([ListParameter(42, 'ids')]),
      );
    });

    test('Parse query with LIKE operator', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM Person WHERE name LIKE :name')
        Future<List<Person>> findPersonsWithNamesLike(String name);
      ''');

      final actual = QueryProcessor(methodElement,
              'SELECT * FROM Person WHERE name LIKE :name', engine)
          .process()
          .sql;

      expect(actual, equals('SELECT * FROM Person WHERE name LIKE ?1'));
    });

    test('Parse query with commas', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :table, :otherTable')
        Future<void> findPersonsWithNamesLike(String table, String otherTable);
      ''');

      final actual =
          QueryProcessor(methodElement, 'SELECT :table, :otherTable', engine)
              .process()
              .sql;

      expect(actual, equals('SELECT ?1, ?2'));
    });

    test('Do not parse parameters in string literals', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :table, :otherTable, \':variable and ?4 \'')
        Future<void> findPersonsWithNamesLike(String table, String otherTable);
      ''');

      final actual = QueryProcessor(methodElement,
              'SELECT :table, :otherTable, \':variable and ?4 \'', engine)
          .process()
          .sql;

      expect(actual, equals('SELECT ?1, ?2, \':variable and ?4 \''));
    });

    test('Parse query with multiple parameters', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :table, :otherTable, :otherTable, :table')
        Future<void> findPersonsWithNamesLike(String table, String otherTable);
      ''');

      final actual = QueryProcessor(methodElement,
              'SELECT :table, :otherTable, :otherTable, :table', engine)
          .process();

      expect(actual.sql, equals('SELECT ?1, ?2, ?2, ?1'));
      expect(actual.listParameters, equals(<ListParameter>[]));
    });

    test('Parse complex query with multiple parameters', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :otherTable, (:list2), :otherTable, (:list1), (:list2), :otherTable, :table, (:list1)')
        Future<void> findPersonsWithNamesLike(String table, String otherTable, List<double> list1, List<bool> list2);
      ''');

      final actual = QueryProcessor(
              methodElement,
              'SELECT :otherTable, (:list2), :otherTable, (:list1), (:list2), :otherTable, :table, (:list1)',
              engine)
          .process();

      expect(
          actual.sql,
          equals(
              'SELECT ?2, (:varlist), ?2, (:varlist), (:varlist), ?2, ?1, (:varlist)'));
      expect(
          actual.listParameters,
          equals([
            ListParameter(12, 'list2'),
            ListParameter(28, 'list1'),
            ListParameter(40, 'list2'),
            ListParameter(60, 'list1'),
          ]));
    });
  });

  group('errors', () {
    test('normal parser exception when query string is malformed', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('FROM Person SELECT 1')
        Future<List<Person>> findAllPersons();
      ''');

      final actual = () =>
          QueryProcessor(methodElement, 'FROM Person SELECT 1', engine)
              .process();
      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError('The query contained parser errors:',
                  element: methodElement)));
    });

    test('parser exception when query string has more than one query',
        () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT 1;SELECT 2')
        Future<List<Person>> findAllPersons();
      ''');

      final actual = () =>
          QueryProcessor(methodElement, 'SELECT 1;SELECT 2', engine).process();
      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError('The query contained parser errors:',
                  element: methodElement)));
    });

    test('analyzer exception when query string contains unknown entity',
        () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT 1 FROM UnknownTable')
        Future<List<Person>> findAllPersons();
      ''');

      final actual = () =>
          QueryProcessor(methodElement, 'SELECT 1 FROM UnknownTable', engine)
              .process();
      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The query contained analyzer errors:',
                  element: methodElement)));
    });

    test('analyzer exception when query string references unknown column',
        () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT unknownColumn FROM Person')
        Future<List<int>> findAllPersons();
      ''');

      final actual = () => QueryProcessor(
              methodElement, 'SELECT unknownColumn FROM Person', engine)
          .process();
      expect(
          actual,
          throwsInvalidGenerationSourceErrorWithMessagePrefix(
              InvalidGenerationSourceError(
                  'The query contained analyzer errors:',
                  element: methodElement)));
    });

    group('parameters', () {
      test('exception when method parameters have an unsupported type',
          () async {
        final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person> findById(Person person);
    ''');

        final actual = () => QueryProcessor(methodElement,
                'SELECT * FROM Person WHERE id = :person', engine)
            .process();
        final parameterElement = methodElement.parameters.first;
        expect(
            actual,
            throwsInvalidGenerationSourceError(
                QueryProcessorError(methodElement).unsupportedParameterType(
                    parameterElement, parameterElement.type)));
      });

      test(
          'exception when method parameters have an unsupported type wrapped in a List',
          () async {
        final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person> findById(List<Person> person);
    ''');

        final actual = () => QueryProcessor(methodElement,
                'SELECT * FROM Person WHERE id = :person', engine)
            .process();
        final parameterElement = methodElement.parameters.first;
        expect(
            actual,
            throwsInvalidGenerationSourceError(
                QueryProcessorError(methodElement).unsupportedParameterType(
                    parameterElement, parameterElement.type.flatten())));
      });

      test('exception when query arguments do not match method parameters',
          () async {
        final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
        Future<Person> findPersonByIdAndName(int id);
      ''');

        final actual = () => QueryProcessor(methodElement,
                'SELECT * FROM Person WHERE id = :id AND name = :name', engine)
            .process();

        expect(
            actual,
            throwsInvalidGenerationSourceErrorWithMessagePrefix(
                InvalidGenerationSourceError(
                    'The named variable in the statement of the `@Query` annotation should exist in the method parameters.',
                    todo:
                        'Please add a method parameter for the variable `:name` with the name `name`.',
                    element: methodElement)));
      });

      test('exception when query arguments do not match method parameters',
          () async {
        final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM Person WHERE id = :id')
        Future<Person> findPersonByIdAndName(int id, String name);
      ''');

        final actual = () => QueryProcessor(
                methodElement, 'SELECT * FROM Person WHERE id = :id', engine)
            .process();
        expect(
            actual,
            throwsInvalidGenerationSourceError(
                QueryProcessorError(methodElement)
                    .methodParameterMissingInQuery(
                        methodElement.parameters.skip(1).first)));
      });

      test('exception when query has numbered variables', () async {
        final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM Person WHERE id = ?1')
        Future<Person> findPersonByIdAndName(int id, String name);
      ''');

        final actual = () => QueryProcessor(
                methodElement, 'SELECT * FROM Person WHERE id = ?1', engine)
            .process();

        expect(
            actual,
            throwsInvalidGenerationSourceErrorWithMessagePrefix(
                InvalidGenerationSourceError(
                    'Statements used in floor should only have named parameters with colons.',
                    todo:
                        'Please use a named variable (`:name`) instead of numbered variables (`?` or `?3`).',
                    element: methodElement)));
      });

      test('exception when query has list parameters without parentheses',
          () async {
        final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM Person WHERE id = :id AND name IN :names')
        Future<Person> findPersonByIdAndName(int id, List<String> names);
      ''');

        final actual = () => QueryProcessor(
                methodElement,
                'SELECT * FROM Person WHERE id = :id AND name IN :names',
                engine)
            .process();

        expect(
            actual,
            throwsInvalidGenerationSourceErrorWithMessagePrefix(
                InvalidGenerationSourceError(
                    'The named variable `:names` referencing a list parameter should be enclosed by parentheses.',
                    todo: 'Please replace `:names` with `(:names)`',
                    element: methodElement)));
      });

      test('Do not parse parameters if it is not an expression', () async {
        final methodElement = await _createQueryMethodElement('''
        @Query('SELECT :table, :otherTable, `:variable`.id FROM Person AS :variable')
        Future<void> findPersonsWithNamesLike(String table, String otherTable);
      ''');

        final actual = () => QueryProcessor(
                methodElement,
                'SELECT :table, :otherTable, `:variable`.id FROM Person AS :variable',
                engine)
            .process();

        expect(
            actual,
            throwsInvalidGenerationSourceErrorWithMessagePrefix(
                InvalidGenerationSourceError(
                    'The query contained parser errors: line 1, column 59: Error: Expected an identifier',
                    element: methodElement)));
      });
    });
  });
}

Future<MethodElement> _createQueryMethodElement(
  final String method,
) async {
  final library = await resolveSource('''
      library test;
      
      import 'dart:typed_data';
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
