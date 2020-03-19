import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../test_util/extensions.dart';
import 'dao/dog_dao.dart';
import 'dao/person_dao.dart';
import 'database.dart';
import 'model/dog.dart';
import 'model/person.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();

  group('database tests', () {
    TestDatabase database;
    PersonDao personDao;
    DogDao dogDao;

    setUp(() async {
      final migration1to2 = Migration(1, 2, (database) async {
        await database.execute('ALTER TABLE dog ADD COLUMN nick_name TEXT');
      });
      final allMigrations = [migration1to2];

      database = await $FloorTestDatabase
          .inMemoryDatabaseBuilder()
          .addMigrations(allMigrations)
          .build();

      personDao = database.personDao;
      dogDao = database.dogDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('database initially is empty', () async {
      final actual = await personDao.findAllPersons();

      expect(actual, isEmpty);
    });

    group('change single item', () {
      test('insert person', () async {
        final person = Person(null, 'Simon');
        await personDao.insertPerson(person);

        final actual = await personDao.findAllPersons();

        expect(actual, hasLength(1));
      });

      test('delete person', () async {
        final person = Person(1, 'Simon');
        await personDao.insertPerson(person);

        await personDao.deletePerson(person);

        final actual = await personDao.findAllPersons();
        expect(actual, isEmpty);
      });

      test('update person', () async {
        final person = Person(1, 'Simon');
        await personDao.insertPerson(person);
        final updatedPerson = Person(person.id, person.name.reversed());

        await personDao.updatePerson(updatedPerson);

        final actual = await personDao.findPersonById(person.id);
        expect(actual, equals(updatedPerson));
      });

      group('change multiple items', () {
        test('insert persons', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

          await personDao.insertPersons(persons);

          final actual = await personDao.findAllPersons();
          expect(actual, equals(persons));
        });

        test('delete persons', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);

          await personDao.deletePersons(persons);

          final actual = await personDao.findAllPersons();
          expect(actual, isEmpty);
        });

        test('update persons', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);
          final updatedPersons = persons
              .map((person) => Person(person.id, person.name.reversed()))
              .toList();

          await personDao.updatePersons(updatedPersons);

          final actual = await personDao.findAllPersons();
          expect(actual, equals(updatedPersons));
        });
      });

      group('querying', () {
        test('query with two parameters (int, String)', () async {
          final person = Person(1, 'Frank');
          await personDao.insertPerson(person);

          final actual = await personDao.findPersonByIdAndName(1, 'Frank');

          expect(actual, equals(person));
        });
      });

      group('transaction', () {
        test('replace persons in transaction', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);
          final newPersons = [Person(3, 'Paul'), Person(4, 'Karl')];

          await personDao.replacePersons(newPersons);

          final actual = await personDao.findAllPersons();
          expect(actual, equals(newPersons));
        });

        test('Reactivity is retained when using transactions', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);
          final newPersons = [Person(3, 'Paul'), Person(4, 'Karl')];

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits(persons));
          await personDao.replacePersons(newPersons);

          expect(actual, emits(newPersons));
        });
      });

      group('change items and return int/list of int', () {
        test('insert person and return id of inserted item', () async {
          final person = Person(1, 'Simon');

          final actual = await personDao.insertPersonWithReturn(person);

          expect(actual, equals(person.id));
        });

        test('insert persons and return ids of inserted items', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

          final actual = await personDao.insertPersonsWithReturn(persons);

          final expected = persons.map((person) => person.id).toList();
          expect(actual, equals(expected));
        });

        test('update person and return 1 (affected row count)', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);
          final updatedPerson = Person(person.id, person.name.reversed());

          final actual = await personDao.updatePersonWithReturn(updatedPerson);

          final persistentPerson = await personDao.findPersonById(person.id);
          expect(persistentPerson, equals(updatedPerson));
          expect(actual, equals(1));
        });

        test('update persons and return affected rows count', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);
          final updatedPersons = persons
              .map((person) => Person(person.id, person.name.reversed()))
              .toList();

          final actual =
              await personDao.updatePersonsWithReturn(updatedPersons);

          final persistentPersons = await personDao.findAllPersons();
          expect(persistentPersons, equals(updatedPersons));
          expect(actual, equals(2));
        });

        test('delete person and return 1 (affected row count)', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);

          final actual = await personDao.deletePersonWithReturn(person);

          expect(actual, equals(1));
        });

        test('delete persons and return affected rows count', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);

          final actual = await personDao.deletePersonsWithReturn(persons);

          expect(actual, equals(2));
        });
      });

      group('foreign key', () {
        test('foreign key constraint failed exception', () {
          final dog = Dog(null, 'Peter', 'Pete', 2);

          expect(() => dogDao.insertDog(dog), _throwsDatabaseException);
        });

        test('find dog for person', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);
          final dog = Dog(2, 'Peter', 'Pete', person.id);
          await dogDao.insertDog(dog);

          final actual = await dogDao.findDogForPersonId(person.id);

          expect(actual, equals(dog));
        });

        test('cascade delete dog on deletion of person', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);
          final dog = Dog(2, 'Peter', 'Pete', person.id);
          await dogDao.insertDog(dog);

          await personDao.deletePerson(person);
          final actual = await dogDao.findAllDogs();

          expect(actual, isEmpty);
        });
      });

      group('query with void return', () {
        test('delete all persons', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);

          await personDao.deleteAllPersons();
          final actual = await personDao.findAllPersons();

          expect(actual, isEmpty);
        });
      });

      group('IN clause', () {
        test('Find persons with IDs', () async {
          final person1 = Person(1, 'Simon');
          final person2 = Person(2, 'Frank');
          final person3 = Person(3, 'Paul');
          await personDao.insertPersons([person1, person2, person3]);
          final ids = [person1.id, person2.id];

          final actual = await personDao.findPersonsWithIds(ids);

          expect(actual, equals([person1, person2]));
        });

        test('Find persons with names', () async {
          final person1 = Person(1, 'Simon');
          final person2 = Person(2, 'Simon');
          final person3 = Person(3, 'Paul');
          await personDao.insertPersons([person1, person2, person3]);
          final names = [person1.name, person2.name];

          final actual = await personDao.findPersonsWithNames(names);

          expect(actual, equals([person1, person2]));
        });
      });

      group('LIKE operator', () {
        test('Find persons with name LIKE', () async {
          final persons = [
            Person(1, 'Simon'),
            Person(2, 'Frank'),
            Person(3, 'Paul')
          ];
          await personDao.insertPersons(persons);

          final actual = await personDao.findPersonsWithNamesLike('%a%');

          final expectedPersons =
              persons.where((person) => person.name.contains('a'));
          expect(actual, equals(expectedPersons));
        });
      });
    });
  });
}

final _throwsDatabaseException =
    throwsA(const TypeMatcher<DatabaseException>());
