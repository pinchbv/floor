import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();

  group('database tests', () {
    ViewTestDatabase database;
    PersonDao personDao;
    DogDao dogDao;
    NameDao nameDao;

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

      test('query view with all values', () async {
        final persons = [Person(1, 'Leo'), Person(2, 'Frank')];
        await personDao.insertPersons(persons);

        final dog = Dog(1, 'Romeo', 'Rome', 1);
        await dogDao.insertDog(dog);

        final actual = await nameDao.findAllNames();

        final expected = [Name('Frank'), Name('Leo'), Name('Romeo')];
        expect(actual, equals(expected));
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
