import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  List<Entity> entities;

  setUpAll(() async => entities = await _getEntities());

  test('Includes methods from abstract parent class', () async {
    final classElement = await _createDao('''
      @dao
      abstract class PersonDao extends AbstractDao<Person> {
        @Query('SELECT * FROM person')
        Future<List<Person>> findAllPersons();
      }
      
      abstract class AbstractDao<T> {
        @insert
        Future<void> insertItem(T item);
      }
    ''');

    final actual = DaoProcessor(classElement, '', '', entities, [])
        .process()
        .methodsLength;

    expect(actual, equals(2));
  });

  test("Includes methods from abstract parent's abstract parent class",
      () async {
    final classElement = await _createDao('''
      @dao
      abstract class PersonDao extends AbstractDao<Person> {
        @Query('SELECT * FROM person')
        Future<List<Person>> findAllPersons();
      }

      abstract class AbstractDao<T> extends AnotherAbstractDao<T> {
        @insert
        Future<void> insertItem(T item);
      }
      
      abstract class AnotherAbstractDao<T> {
        @update
        Future<void> updateItem(T item);      
      }
    ''');

    final actual = DaoProcessor(classElement, '', '', entities, [])
        .process()
        .methodsLength;

    expect(actual, equals(3));
  });

  test('Includes methods from mixin', () async {
    final classElement = await _createDao('''
      @dao
      abstract class PersonDao with MixinDao<Person> {
        @Query('SELECT * FROM person')
        Future<List<Person>> findAllPersons();
      }

      class MixinDao<T> {
        @insert
        Future<void> insertItem(T item);
      }
    ''');

    final actual = DaoProcessor(classElement, '', '', entities, [])
        .process()
        .methodsLength;

    expect(actual, equals(2));
  });

  test('Includes methods from super class', () async {
    final classElement = await _createDao('''
      @dao
      abstract class PersonDao extends SuperClassDao<Person> {
        @Query('SELECT * FROM person')
        Future<List<Person>> findAllPersons();
      }

      class SuperClassDao<T> {
        @insert
        Future<void> insertItem(T item);
      }
    ''');

    final actual = DaoProcessor(classElement, '', '', entities, [])
        .process()
        .methodsLength;

    expect(actual, equals(2));
  });

  test('Includes methods from interface', () async {
    final classElement = await _createDao('''
      @dao
      abstract class PersonDao implements InterfaceDao<Person> {
        @Query('SELECT * FROM person')
        Future<List<Person>> findAllPersons();
      }

      class InterfaceDao<T> {
        @insert
        Future<void> insertItem(T item);
      }
    ''');

    final actual = DaoProcessor(classElement, '', '', entities, [])
        .process()
        .methodsLength;

    expect(actual, equals(2));
  });
}

extension on Dao {
  int get methodsLength {
    return [
      ...queryMethods,
      ...insertionMethods,
      ...updateMethods,
      ...deletionMethods,
      ...transactionMethods
    ].length;
  }
}

Future<ClassElement> _createDao(final String dao) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $dao
      
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

  return library.classes.first;
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
