import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:sqflite/sqflite.dart';

import 'dao/dog_dao.dart';
import 'dao/person_dao.dart';
import 'database.dart';
import 'model/dog.dart';
import 'model/person.dart';

// run test with 'flutter run test/database_test.dart'
// trigger generator with 'flutter packages pub run build_runner build'
void main() {
  group('database tests', () {
    TestDatabase database;
    PersonDao personDao;
    DogDao dogDao;

    setUpAll(() async {
      final migration1to2 = Migration(1, 2, (database) {
        database.execute('ALTER TABLE dog ADD COLUMN nick_name TEXT');
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
      await database.database.execute('DELETE FROM dog');
      await database.database.execute('DELETE FROM person');
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
        final updatedPerson = Person(person.id, _reverse(person.name));

        await personDao.updatePerson(updatedPerson);

        final actual = await personDao.findPersonById(person.id);
        expect(actual, equals(updatedPerson));
      });
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
            .map((person) => Person(person.id, _reverse(person.name)))
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
        final updatedPerson = Person(person.id, _reverse(person.name));

        final actual = await personDao.updatePersonWithReturn(updatedPerson);

        final persistentPerson = await personDao.findPersonById(person.id);
        expect(persistentPerson, equals(updatedPerson));
        expect(actual, equals(1));
      });

      test('update persons and return affected rows count', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);
        final updatedPersons = persons
            .map((person) => Person(person.id, _reverse(person.name)))
            .toList();

        final actual = await personDao.updatePersonsWithReturn(updatedPersons);

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

    group('stream queries', () {
      test('initially emit persistent data', () async {
        final person = Person(1, 'Simon');
        await personDao.insertPerson(person);

        final actual = personDao.findAllPersonsAsStream();

        expect(actual, emits([person]));
      });

      group('insert change', () {
        test('find person by id as stream', () async {
          final person = Person(1, 'Simon');

          final actual = personDao.findPersonByIdAsStream(person.id);

          await personDao.insertPerson(person);
          expect(actual, emits(person));
        });

        test('find all persons as stream', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits(<List<Person>>[]));

          await personDao.insertPersons(persons);
          expect(actual, emits(persons));
        });

        test('initially emits persistent data then new', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          final persons2 = [Person(3, 'Paul'), Person(4, 'George')];
          await personDao.insertPersons(persons);

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits(persons));

          await personDao.insertPersons(persons2);
          expect(actual, emits(persons + persons2));
        });
      });

      group('update change', () {
        test('update item', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits([person]));

          final updatedPerson = Person(person.id, 'Frank');
          await personDao.updatePerson(updatedPerson);
          expect(actual, emits([updatedPerson]));
        });

        test('update items', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          final updatedPersons = persons
              .map((person) => Person(person.id, _reverse(person.name)))
              .toList();
          await personDao.insertPersons(persons);

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits(persons));

          await personDao.updatePersons(updatedPersons);
          expect(actual, emits(updatedPersons));
        });
      });

      group('deletion change', () {
        test('delete item', () async {
          final person = Person(1, 'Simon');
          await personDao.insertPerson(person);

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits([person]));

          await personDao.deletePerson(person);
          expect(actual, emits(<Person>[]));
        });

        test('delete items', () async {
          final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
          await personDao.insertPersons(persons);

          final actual = personDao.findAllPersonsAsStream();
          expect(actual, emits(persons));

          await personDao.deletePersons(persons);
          expect(actual, emits(<Person>[]));
        });
      });
    });

    group('IN clause', () {
      test('Find persons with IDs', () async {
        final person1 = Person(1, 'Simon');
        final person2 = Person(2, 'Frank');
        final person3 = Person(3, 'Paul');
        final allPersons = [person1, person2, person3];
        await personDao.insertPersons(allPersons);
        final ids = [person1.id, person2.id];

        final actual = await personDao.findPersonWithIds(ids);

        expect(actual, equals([person1, person2]));
      });
    });
  });
}

final _throwsDatabaseException =
    throwsA(const TypeMatcher<DatabaseException>());

String _reverse(final String value) {
  return value.split('').reversed.join();
}
