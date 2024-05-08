import 'package:test/test.dart';

import '../test_util/extensions.dart';
import 'dao/person_dao.dart';
import 'database.dart';
import 'model/dog.dart';
import 'model/person.dart';

void main() {
  group('stream query tests', () {
    late TestDatabase database;
    late PersonDao personDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      personDao = database.personDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('initially emit persistent data', () async {
      final person = Person(1, 'Simon');
      await personDao.insertPerson(person);

      final actual = personDao.findAllPersonsAsStream();

      expect(actual, emits([person]));
    });

    group('insert change', () {
      test('find person by id as stream', () async {
        final person = Person(1, 'Simon');
        await personDao.insertPerson(person);

        final actual = personDao.findPersonByIdAsStream(person.id!);

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

      test('unique records count', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        final persons2 = [Person(3, 'Paul'), Person(4, 'George')];
        await personDao.insertPersons(persons);

        final actual = personDao.uniqueRecordsCountAsStream();
        expect(actual, emits(persons.length));

        await personDao.insertPersons(persons2);
        expect(actual, emits(persons.length + persons2.length));
      });
    });

    group('update change', () {
      test('update item when querying single item', () async {
        final person = Person(1, 'Simon');
        final updatedPerson = Person(person.id, 'Frank');
        await personDao.insertPerson(person);

        final actual = personDao.findPersonByIdAsStream(person.id!);
        expect(actual, emits(person));
        await personDao.updatePerson(updatedPerson);

        expect(actual, emits(updatedPerson));
      });

      test('update item when querying list of items', () async {
        final person = Person(1, 'Simon');
        await personDao.insertPerson(person);

        final actual = personDao.findAllPersonsAsStream();
        expect(actual, emits([person]));

        final updatedPerson = Person(person.id, 'Frank');
        await personDao.updatePerson(updatedPerson);
        expect(actual, emits([updatedPerson]));
      });

      test('update items when querying list of items', () async {
        final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
        final updatedPersons = persons
            .map((person) => Person(person.id, person.name.reversed()))
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

    test('regression test streaming updates from other Dao', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final dog1 = Dog(1, 'Dog', 'Doggie', person1.id!);
      final dog2 = Dog(2, 'OtherDog', 'Doggo', person2.id!);

      final actual = personDao.findAllDogsOfPersonAsStream(person1.id!);
      expect(
          actual,
          emitsInOrder(<List<Dog>>[
            [], // initial state,
            [dog1], // after inserting dog1
            [dog1], // after inserting dog2
            //[], // after removing person1. Does not work because
            // ForeignKey-relations are not considered yet (#321)
          ]));

      await personDao.insertPerson(person1);
      await personDao.insertPerson(person2);

      await database.dogDao.insertDog(dog1);

      await database.dogDao.insertDog(dog2);

      // avoid that delete happens before the re-execution of
      // the select query for the stream
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await database.personDao.deletePerson(person1);
    });
  });
}
