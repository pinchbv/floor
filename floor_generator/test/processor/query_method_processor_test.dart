import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/error/query_processor_error.dart';
import 'package:floor_generator/processor/query_method_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  late List<Entity> entities;
  late List<View> views;

  setUpAll(() async {
    entities = await _getEntities();
    views = await _getViews();
  });

  test('create query method', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();      
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [...entities, ...views], {})
            .process();

    expect(
      actual,
      equals(
        QueryMethod(
          methodElement,
          'findAllPersons',
          Query('SELECT * FROM Person', []),
          await getDartTypeWithPerson('Future<List<Person>>'),
          await getDartTypeWithPerson('Person'),
          [],
          entities.first,
          {},
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
        QueryMethodProcessor(methodElement, [...entities, ...views], {})
            .process();

    expect(
      actual,
      equals(
        QueryMethod(
          methodElement,
          'findAllNames',
          Query('SELECT * FROM name', []),
          await getDartTypeWithName('Future<List<Name>>'),
          await getDartTypeWithName('Name'),
          [],
          views.first,
          {},
        ),
      ),
    );
  });

  group('query parsing', () {
    test('parse query', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person?> findPerson(int id);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(actual.sql, equals('SELECT * FROM Person WHERE id = ?1'));
      expect(actual.queryParameters, equals(<QueryParameter>[
        QueryParameter(32, 'id', ParamType.normal)
      ]));
    });

    test('parse query reusing a single parameter', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id AND id = :id')
      Future<Person?> findPerson(int id);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;

      expect(actual, equals('SELECT * FROM Person WHERE id = ?1 AND id = ?1'));
    });

    test('parse query with multiple unordered parameters', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE name = :name AND id = :id AND id = :id AND name = :name')
      Future<Person?> findPerson(int id, String name);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;

      expect(
          actual,
          equals('SELECT * FROM Person WHERE name = ?2'
              ' AND id = ?1 AND id = ?1 AND name = ?2'));
    });

    test('parse multiline query', () async {
      final methodElement = await _createQueryMethodElement("""
        @Query('''
          SELECT * FROM person
          WHERE id = :id AND custom_name = :name
        ''')
        Future<Person?> findPersonByIdAndName(int id, String name);
      """);

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;

      expect(
        actual,
        equals(
            'SELECT * FROM person           WHERE id = ?1 AND custom_name = ?2'),
      );
    });

    test('parse concatenated string query', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM person '
            'WHERE id = :id AND custom_name = :name')
        Future<Person?> findPersonByIdAndName(int id, String name);    
      ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ?1 AND custom_name = ?2'),
      );
    });

    test('Parse IN clause', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids)')
      Future<void> setRated(List<int> ids);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(r'update sports set rated = 1 where id in (:varlist)'),
      );
      expect(actual.queryParameters, equals([QueryParameter(41, 'ids', ParamType.list)]));
    });

    test('parses IN clause without space after IN', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in(:ids)')
      Future<void> setRated(List<int> ids);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(r'update sports set rated = 1 where id in(:varlist)'),
      );
      expect(actual.queryParameters, equals([QueryParameter(40, 'ids', ParamType.list)]));
    });

    test('parses IN clause with multiple spaces after IN', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in      (:ids)')
      Future<void> setRated(List<int> ids);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(r'update sports set rated = 1 where id in      (:varlist)'),
      );
      expect(actual.queryParameters, equals([QueryParameter(46, 'ids', ParamType.list)]));
    });

    test('Parse query with multiple IN clauses', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) and where foo in (:bar)')
      Future<void> setRated(List<int> ids, List<int> bar);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(
          r'update sports set rated = 1 where id in (:varlist) '
          r'and where foo in (:varlist)',
        ),
      );
      expect(actual.queryParameters,
          equals([QueryParameter(41, 'ids', ParamType.list), QueryParameter(69, 'bar', ParamType.list)]));
    });

    test('Parse query with IN clause and other parameter', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) AND foo = :bar')
      Future<void> setRated(List<int> ids, int bar);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(
          r'update sports set rated = 1 where id in (:varlist) AND foo = ?1',
        ),
      );
      expect(actual.queryParameters, equals([
        QueryParameter(41, 'ids', ParamType.list),
        QueryParameter(61, 'bar', ParamType.normal),
      ]));
    });

    test('Parse query with mixed IN clauses and other parameters', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) AND foo = :bar AND name in (:names) and :bar = :foo')
      Future<void> setRated(String foo, List<String> names, List<int> ids, int bar);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query;

      expect(
        actual.sql,
        equals(
          r'update sports set rated = 1 where id in (:varlist) AND foo = ?2 '
          r'AND name in (:varlist) and ?2 = ?1',
        ),
      );
      expect(actual.queryParameters,
          equals([
            QueryParameter(41, 'ids', ParamType.list),
            QueryParameter(61, 'bar', ParamType.normal),
            QueryParameter(77, 'names', ParamType.list),
            QueryParameter(91, 'bar', ParamType.normal),
            QueryParameter(96, 'foo', ParamType.normal),
          ]));
    });

    test('Parse query with LIKE operator', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Persons WHERE name LIKE :name')
      Future<List<Person>> findPersonsWithNamesLike(String name);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;

      expect(actual, equals('SELECT * FROM Persons WHERE name LIKE ?1'));
    });

    test('Parse query with commas', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM :table, :otherTable')
      Future<List<Person>> findPersonsWithNamesLike(String table, String otherTable);
    ''');

      final actual =
          QueryMethodProcessor(methodElement, [], {}).process().query.sql;
      // note: this will throw an error at runtime, because
      // sqlite variables can not be used in place of table
      // names. But the Processor is not aware of this.
      expect(actual, equals('SELECT * FROM ?1, ?2'));
    });
  });

  test('Parse query with single custom str', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('my name is cola , nice to meet u {tt1}')
      Future<void> setRated(String tt1);
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [], {}).process().query;

    expect(
      actual.sql,
      equals(
        r'my name is cola , nice to meet u {tt1}'
      ),
    );
    expect(actual.queryParameters,
        equals([
          QueryParameter(33, 'tt1', ParamType.custom),
        ]));
  });

  test('Parse query with multiple custom str', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('my name is cola , nice to meet u {tt1} {tt1}')
      Future<void> setRated(String tt1);
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [], {}).process().query;

    expect(
      actual.sql,
      equals(
        r'my name is cola , nice to meet u {tt1} {tt1}'
      ),
    );
    expect(actual.queryParameters,
        equals([
          QueryParameter(33, 'tt1', ParamType.custom),
          QueryParameter(39, 'tt1', ParamType.custom),
        ]));
  });

  test('Parse query with multiple custom str and normal multiple parameter', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('my name is cola , nice to meet u {tt1} {foo} :bar = :foo')
      Future<void> setRated(String tt1, String foo, int bar);
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [], {}).process().query;

    expect(
      actual.sql,
      equals(
        r'my name is cola , nice to meet u {tt1} {foo} ?2 = ?1'
      ),
    );
    expect(actual.queryParameters,
        equals([
          QueryParameter(33, 'tt1', ParamType.custom),
          QueryParameter(39, 'foo', ParamType.custom),
          QueryParameter(45, 'bar', ParamType.normal),
          QueryParameter(50, 'foo', ParamType.normal),
        ]));
  });

  test('Parse query with multiple custom str and normal multiple parameter and multiple list parameter', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('my name is cola in(:ids) In (:ids), nice to meet u {tt1} {foo} :bar = :foo')
      Future<void> setRated(String tt1, bool foo, int bar, List<int> ids);
    ''');

    final actual =
        QueryMethodProcessor(methodElement, [], {}).process().query;

    expect(
      actual.sql,
      equals(
        r'my name is cola in(:varlist) In (:varlist), nice to meet u {tt1} {foo} ?2 = ?1'
      ),
    );
    expect(actual.queryParameters,
        equals([
          QueryParameter(19, 'ids', ParamType.list),
          QueryParameter(33, 'ids', ParamType.list),
          QueryParameter(59, 'tt1', ParamType.custom),
          QueryParameter(65, 'foo', ParamType.custom),
          QueryParameter(71, 'bar', ParamType.normal),
          QueryParameter(76, 'foo', ParamType.normal),
        ]));
  });

  group('errors', () {
    test('exception when method does not return future', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      List<Person?> findAllPersons();
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
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
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
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
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final error = QueryMethodProcessorError(methodElement).noQueryDefined;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test(
        'exception when query arguments do not match method parameters, no list vs list',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person?> findPersonByIdAndName(List<int> id);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final error = QueryProcessorError(methodElement)
          .queryMethodParameterIsListButVariableIsNot(':id');
      expect(actual, throwsProcessorError(error));
    });

    test(
        'exception when query arguments do not match method parameters, list vs no list',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id IN (:id)')
      Future<Person?> findPersonByIdAndName(int id);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final error = QueryProcessorError(methodElement)
          .queryMethodParameterIsNormalButVariableIsList(':id');
      expect(actual, throwsProcessorError(error));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
      Future<Person?> findPersonByIdAndName(int id);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final error =
          QueryProcessorError(methodElement).unknownQueryVariable(':name');
      expect(actual, throwsProcessorError(error));
    });

    test('exception when passing nullable method parameter to query method',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person?> findPersonByIdAndName(int? id);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final parameterElement = methodElement.parameters.first;
      final error = QueryProcessorError(methodElement)
          .queryMethodParameterIsNullable(parameterElement);
      expect(actual, throwsProcessorError(error));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person?> findPersonByIdAndName(int id, String name);
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      final error = QueryProcessorError(methodElement)
          .unusedQueryMethodParameter(methodElement.parameters[1]);
      expect(actual, throwsProcessorError(error));
    });

    test(
        'throws when method returns Future of non-nullable type for single item query',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPersonById(int id);      
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      expect(actual, throwsProcessorError());
    });

    test(
        'throws when method returns Stream of non-nullable type for single item query',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Stream<Person> findPersonById(int id);      
    ''');

      final actual = () =>
          QueryMethodProcessor(methodElement, [...entities, ...views], {})
              .process();

      expect(actual, throwsProcessorError());
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
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
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
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, {}).process())
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
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  return library.classes
      .where((classElement) =>
          classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement, {}).process())
      .toList();
}
