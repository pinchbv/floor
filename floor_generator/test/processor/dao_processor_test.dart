import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
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

    entities = await getEntities();
    entities.forEach(engine.registerEntity);

    views = await getViews();
    views.forEach(engine.checkAndRegisterView);
  });

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

    final actual = DaoProcessor(classElement, '', '', entities, views, engine)
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

    final actual = DaoProcessor(classElement, '', '', entities, views, engine)
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

    final actual = DaoProcessor(classElement, '', '', entities, views, engine)
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

    final actual = DaoProcessor(classElement, '', '', entities, views, engine)
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

    final actual = DaoProcessor(classElement, '', '', entities, views, engine)
        .process()
        .methodsLength;

    expect(actual, equals(2));
  });

  test('Includes streamable view method from super class', () async {
    final classElement = await _createDao('''
        @dao
        abstract class PersonDao extends SuperClassDao<Person> {
          @Query('SELECT * FROM person')
          Future<List<Person>> findAllPersons();

          @Query('SELECT Name.name from Name')
          Stream<List<Name>> getAllNamesStream();
        }

        class SuperClassDao<T> {
          @insert
          Future<void> insertItem(T item);

          @Query('SELECT DISTINCT Name.name from Name')
          Stream<List<Name>> getAllDistinctNamesStream();
        }
      ''');

    final processedDao =
        DaoProcessor(classElement, '', '', entities, views, engine).process();

    expect(processedDao.methodsLength, equals(4));
    expect(processedDao.streamEntities, equals(<Entity>[entities.first]));
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
      
      @DatabaseView("SELECT name FROM Person")
      class Name {
        final String name;
      
        Person(this.name);
      }

      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first;
}
