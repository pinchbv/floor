import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';

// run test with 'flutter run test/database_test.dart'
void main() {
  group('database tests', () {
    TestDatabase database;

    setUpAll(() async {
      database = await TestDatabase.openDatabase();
      await database.database.execute('DELETE FROM dog');
      await database.database.execute('DELETE FROM person');
    });

    tearDown(() async {
      await database.database.execute('DELETE FROM dog');
      await database.database.execute('DELETE FROM person');
    });

    test('database initially is empty', () async {
      final actual = await database.findAllPersons();

      expect(actual, isEmpty);
    });

    group('change single item', () {
      test('insert person', () async {
        final person = Person(null, 'Simon');
        await database.insertPerson(person);

        final actual = await database.findAllPersons();

        expect(actual, hasLength(1));
      });

      test('delete person', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);

        await database.deletePerson(person);

        final actual = await database.findAllPersons();
        expect(actual, isEmpty);
      });

      test('update person', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);
        final updatedPerson = Person(person.id, _reverse(person.name));

        await database.updatePerson(updatedPerson);

        final actual = await database.findPersonById(person.id);
        expect(actual, equals(updatedPerson));
      });
    });

    group('change multiple items', () {
      test('insert persons', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

        await database.insertPersons(persons);

        final actual = await database.findAllPersons();
        expect(actual, equals(persons));
      });

      test('delete persons', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);

        await database.deletePersons(persons);

        final actual = await database.findAllPersons();
        expect(actual, isEmpty);
      });

      test('update persons', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);
        final updatedPersons = persons
            .map((person) => Person(person.id, _reverse(person.name)))
            .toList();

        await database.updatePersons(updatedPersons);

        final actual = await database.findAllPersons();
        expect(actual, equals(updatedPersons));
      });
    });

    group('transaction', () {
      test('replace persons in transaction', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);
        final newPersons = [Person(3, 'Paul'), Person(4, 'Karl')];

        await database.replacePersons(newPersons);

        final actual = await database.findAllPersons();
        expect(actual, equals(newPersons));
      });
    });

    group('change items and return int/list of int', () {
      test('insert person and return id of inserted item', () async {
        final person = Person(1, 'Simon');

        final actual = await database.insertPersonWithReturn(person);

        expect(actual, equals(person.id));
      });

      test('insert persons and return ids of inserted items', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];

        final actual = await database.insertPersonsWithReturn(persons);

        final expected = persons.map((person) => person.id).toList();
        expect(actual, equals(expected));
      });

      test('update person and return 1 (affected row count)', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);
        final updatedPerson = Person(person.id, _reverse(person.name));

        final actual = await database.updatePersonWithReturn(updatedPerson);

        final persistentPerson = await database.findPersonById(person.id);
        expect(persistentPerson, equals(updatedPerson));
        expect(actual, equals(1));
      });

      test('update persons and return affected rows count', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);
        final updatedPersons = persons
            .map((person) => Person(person.id, _reverse(person.name)))
            .toList();

        final actual = await database.updatePersonsWithReturn(updatedPersons);

        final persistentPersons = await database.findAllPersons();
        expect(persistentPersons, equals(updatedPersons));
        expect(actual, equals(2));
      });

      test('delete person and return 1 (affected row count)', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);

        final actual = await database.deletePersonWithReturn(person);

        expect(actual, equals(1));
      });

      test('delete persons and return affected rows count', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);

        final actual = await database.deletePersonsWithReturn(persons);

        expect(actual, equals(2));
      });
    });

    group('foreign key', () {
      test('foreign key constraint failed exception', () {
        final dog = Dog(null, 'Peter', 2);

        expect(() => database.insertDog(dog), _throwsDatabaseException);
      });

      test('find dog for person', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);
        final dog = Dog(2, 'Peter', person.id);
        await database.insertDog(dog);

        final actual = await database.findDogForPersonId(person.id);

        expect(actual, equals(dog));
      });

      test('cascade delete dog on deletion of person', () async {
        final person = Person(1, 'Simon');
        await database.insertPerson(person);
        final dog = Dog(2, 'Peter', person.id);
        await database.insertDog(dog);

        await database.deletePerson(person);
        final actual = await database.findAllDogs();

        expect(actual, isEmpty);
      });
    });

    group('query with void return', () {
      test('delete all persons', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        await database.insertPersons(persons);

        await database.deleteAllPersons();
        final actual = await database.findAllPersons();

        expect(actual, isEmpty);
      });
    });
  });
}

final _throwsDatabaseException = throwsA(const TypeMatcher<DatabaseException>());

String _reverse(final String value) {
  return value.split('').reversed.join();
}
