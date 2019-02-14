import 'package:flutter_test/flutter_test.dart';

import 'database.dart';

// run test with 'flutter run test/database_test.dart'
void main() {
  group('database tests', () {
    TestDatabase database;

    setUpAll(() async {
      database = await TestDatabase.openDatabase();
    });

    tearDown(() async {
      await database.database.execute('DELETE FROM person');
    });

    test('database initially is empty', () async {
      final actual = await database.findAllPersons();

      expect(actual, isEmpty);
    });

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

      final updatedPerson = Person(person.id, 'Frank');
      await database.updatePerson(updatedPerson);

      final actual = await database.findPersonById(person.id);
      expect(actual, equals(updatedPerson));
    });

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
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      await database.insertPersons(persons);

      final updatedPersons = [
        Person(person1.id, _reverse(person1.name)),
        Person(person2.id, _reverse(person2.name))
      ];
      await database.updatePersons(updatedPersons);

      final actual = await database.findAllPersons();
      expect(actual, equals(updatedPersons));
    });

    test('replace persons in transaction', () async {
      final persons = [Person(1, 'Simon'), Person(2, 'Frank')];
      await database.insertPersons(persons);

      final newPersons = [Person(3, 'Paul'), Person(4, 'Karl')];
      await database.replacePersons(newPersons);

      final actual = await database.findAllPersons();
      expect(actual, equals(newPersons));
    });
  });
}

String _reverse(String value) {
  return value.split('').reversed.join();
}
