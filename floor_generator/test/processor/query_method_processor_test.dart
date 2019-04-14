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

Future<void> main() async {
  final entities = await _getEntities();

  test('create query method', () async {
    final methodElement = await _createQueryMethodClassElement('''
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

  group('errors', () {
    test('exception when method does not return future', () async {
      final methodElement = await _createQueryMethodClassElement('''
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
      final methodElement = await _createQueryMethodClassElement('''
      @Query('')
      Future<List<Person>> findAllPersons();
    ''');

      final actual =
          () => QueryMethodProcessor(methodElement, entities).process();

      final error = QueryMethodProcessorError(methodElement).NO_QUERY_DEFINED;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });

    test('exception when query is null', () async {
      final methodElement = await _createQueryMethodClassElement('''
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
      final methodElement = await _createQueryMethodClassElement('''
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
      final methodElement = await _createQueryMethodClassElement('''
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

Future<MethodElement> _createQueryMethodClassElement(
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
