import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/query_method_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  List<Entity> entities;

  setUpAll(() async => entities = await _getEntities());

  test('create query method', () async {
    final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();      
    ''');

    final actual = QueryMethodProcessor(methodElement, entities).process();

    expect(
      actual,
      equals(
        QueryMethod(
          methodElement,
          'findAllPersons',
          'SELECT * FROM Person',
          await getDartTypeWithPerson('Future<List<Person>>'),
          await getDartTypeWithPerson('Person'),
          [],
          entities.first,
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

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(actual, equals('SELECT * FROM Person WHERE id = ?'));
    });

    test('parse multiline query', () async {
      final methodElement = await _createQueryMethodElement("""
        @Query('''
          SELECT * FROM person
          WHERE id = :id AND custom_name = :name
        ''')
        Future<Person> findPersonByIdAndName(int id, String name);
      """);

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ? AND custom_name = ?'),
      );
    });

    test('parse concatenated string query', () async {
      final methodElement = await _createQueryMethodElement('''
        @Query('SELECT * FROM person '
            'WHERE id = :id AND custom_name = :name')
        Future<Person> findPersonByIdAndName(int id, String name);    
      ''');

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(
        actual,
        equals('SELECT * FROM person WHERE id = ? AND custom_name = ?'),
      );
    });

    test('Parse IN clause', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids)')
      Future<void> setRated(List<int> ids);
    ''');

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(
        actual,
        equals(r'update sports set rated = 1 where id in ($valueList1)'),
      );
    });

    test('Parse query with multiple IN clauses', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) and where foo in (:bar)')
      Future<void> setRated(List<int> ids, List<int> bar);
    ''');

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(
        actual,
        equals(
          r'update sports set rated = 1 where id in ($valueList1) '
          r'and where foo in ($valueList2)',
        ),
      );
    });

    test('Parse query with IN clause and other parameter', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('update sports set rated = 1 where id in (:ids) AND foo = :bar')
      Future<void> setRated(List<int> ids, int bar);
    ''');

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(
        actual,
        equals(
          r'update sports set rated = 1 where id in ($valueList1) '
          r'AND foo = ?',
        ),
      );
    });

    test('Parse query with LIKE operator', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Persons WHERE name LIKE :name')
      Future<List<Person>> findPersonsWhereNameLike(String name);
    ''');

      final actual = QueryMethodProcessor(methodElement, []).process().query;

      expect(actual, equals('SELECT * FROM Persons WHERE name LIKE ?'));
    });
  });

  group('errors', () {
    test('exception when method does not return future', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person')
      List<Person> findAllPersons();
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement)
          .DOES_NOT_RETURN_FUTURE_NOR_STREAM;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query is empty string', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('')
      Future<List<Person>> findAllPersons();
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement).NO_QUERY_DEFINED;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query is null', () async {
      final methodElement = await _createQueryMethodElement('''
      @Query()
      Future<List<Person>> findAllPersons();
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement).NO_QUERY_DEFINED;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
      Future<Person> findPersonByIdAndName(int id);
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement)
          .QUERY_ARGUMENTS_AND_METHOD_PARAMETERS_DO_NOT_MATCH;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query arguments do not match method parameters',
        () async {
      final methodElement = await _createQueryMethodElement('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPersonByIdAndName(int id, String name);
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement)
          .QUERY_ARGUMENTS_AND_METHOD_PARAMETERS_DO_NOT_MATCH;
      expect(actual, throwsInvalidGenerationSourceError(error));
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
      .where((classElement) =>
          typeChecker(annotations.Entity).hasAnnotationOfExact(classElement))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();
}
