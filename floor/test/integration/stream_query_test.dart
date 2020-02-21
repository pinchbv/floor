import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../test_util/extensions.dart';
import 'dao/person_dao.dart';
import 'database.dart';
import 'model/person.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();

  group('stream query tests', () {
    TestDatabase database;
    PersonDao personDao;

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

        final actual = personDao.findPersonByIdAsStream(person.id);

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
      test('update item when querying single item', () async {
        final person = Person(1, 'Simon');
        final updatedPerson = Person(person.id, 'Frank');
        await personDao.insertPerson(person);

        final actual = personDao.findPersonByIdAsStream(person.id);
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
  });
}
