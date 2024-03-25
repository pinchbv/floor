import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;
import 'package:test/test.dart';

import '../../test_util/database_factory.dart';
import '../dao/dog_dao.dart';
import '../dao/name_dao.dart';
import '../dao/person_dao.dart';
import '../model/dog.dart';
import '../model/mutliline_name.dart';
import '../model/name.dart';
import '../model/person.dart';

part 'view_test.g.dart';

@Database(
  version: 1,
  entities: [Person, Dog],
  views: [Name, MultilineQueryName],
)
abstract class ViewTestDatabase extends FloorDatabase {
  PersonDao get personDao;

  DogDao get dogDao;

  NameDao get nameDao;
}

void main() {
  group('database tests', () {
    late ViewTestDatabase database;
    late PersonDao personDao;
    late DogDao dogDao;
    late NameDao nameDao;

    setUp(() async {
      database = await $FloorViewTestDatabase.inMemoryDatabaseBuilder().build();

      personDao = database.personDao;
      dogDao = database.dogDao;
      nameDao = database.nameDao;
    });

    tearDown(() async {
      await database.close();
    });

    group('Query Views', () {
      test('query view with exact value', () async {
        final person = Person(1, 'Frank');
        await personDao.insertPerson(person);

        final actual = await nameDao.findExactName('Frank');

        final expected = Name('Frank');
        expect(actual, equals(expected));
      });

      test('query view with LIKE', () async {
        final persons = [Person(1, 'Leo'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);

        final dog = Dog(1, 'Romeo', 'Rome', 1);
        await dogDao.insertDog(dog);

        final actual = await nameDao.findNamesLike('%eo');

        final expected = [Name('Leo'), Name('Romeo')];
        expect(actual, equals(expected));
      });

      test('query view with double LIKE (reordered query params)', () async {
        final persons = [Person(1, 'Leo'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);

        final dog = Dog(1, 'Romeo', 'Rome', 1);
        await dogDao.insertDog(dog);

        final actual = await nameDao.findNamesMatchingBoth('L%', '%eo');

        final expected = [Name('Leo')];
        expect(actual, equals(expected));
      });

      test('query view with all values', () async {
        final persons = [Person(1, 'Leo'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);

        final dog = Dog(1, 'Romeo', 'Rome', 1);
        await dogDao.insertDog(dog);

        final actual = await nameDao.findAllNames();

        final expected = [Name('Frank'), Name('Leo'), Name('Romeo')];
        expect(actual, equals(expected));
      });

      test('query view with all values as stream', () async {
        final actual = nameDao.findAllNamesAsStream();
        expect(
            actual,
            emitsInOrder(<List<Name>>[
              [], // initial state
              [Name('Frank'), Name('Leo')], // after inserting Persons
              [
                // after inserting Dog:
                Name('Frank'),
                Name('Leo'),
                Name('Romeo')
              ],
              [
                // after updating Leo:
                Name('Frank'),
                Name('Leonhard'),
                Name('Romeo')
              ],
              [Name('Frank')], // after removing Person (and associated Dog)
            ]));

        final persons = [Person(1, 'Leo'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dog = Dog(1, 'Romeo', 'Rome', 1);
        await dogDao.insertDog(dog);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final renamedPerson = Person(1, 'Leonhard');
        await personDao.updatePerson(renamedPerson);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Also removes the dog which belonged to
        // Leonhard through ForeignKey relations
        await personDao.deletePerson(renamedPerson);
      });

      test('query multiline query view to find name', () async {
        final person = Person(1, 'Frank');
        await personDao.insertPerson(person);

        final actual = await nameDao.findMultilineQueryName('Frank');

        final expected = MultilineQueryName('Frank');
        expect(actual, equals(expected));
      });
    });
  });
}
