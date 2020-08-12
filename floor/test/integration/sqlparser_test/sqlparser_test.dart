import 'dart:async';

import 'package:floor/floor.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../model/person.dart';

part 'sqlparser_test.g.dart';

void main() {
  TestDatabase database;
  DeepDao deepDao;
  CaseDao caseDao;

  setUp(() async {
    database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
    deepDao = database.deepDao;
    caseDao = database.caseDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('Stream works with wrong case', () async {
    final person1 = Person(1, 'Baba');
    final person2 = Person(2, 'Me');

    final actual = caseDao.allPersons();
    expect(
        actual,
        emitsInOrder(<List<Person>>[
          [],
          [],
          [person1],
          [person1],
          [person1, person2],
          [person1, person2],
        ]));
    // delay execution to make sure that the stream is updated in between
    // (and not multiple times afterwards)
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await caseDao.updateName();

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await caseDao.insertPerson(person1);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await caseDao.updateName();

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await caseDao.insertPerson(person2);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await caseDao.updateName();
  });

  group('Function type derivation tests', () {
    test('try IN with null list', () async {
      final list = ['a', 'b', 'c', 'd', 'e', 'f', null];

      final aInList = await deepDao.isXinList('a', list);
      expect(aInList, equals(true));

      final yInList = await deepDao.isXinList('y', list);
      expect(yInList, equals(null));

      final nullInList = await deepDao.isXinList(null, list);
      expect(nullInList, equals(null));
    });

    test('try IN with non-null list', () async {
      final list = ['a', 'b', 'c', 'd', 'e', 'f'];

      final aInList = await deepDao.isXinList('a', list);
      expect(aInList, equals(true));

      final yInList = await deepDao.isXinList('y', list);
      expect(yInList, equals(false));

      final nullInList = await deepDao.isXinList(null, list);
      expect(nullInList, equals(null));
    });

    test('try plus-null', () async {
      expect(await deepDao.plusString(null), equals(null));
    });

    test('try plus-22', () async {
      expect(await deepDao.plusString('22'), equals(66));
    });

    test('try plus-8h', () async {
      expect(await deepDao.plusString('8h'), equals(24));
    });

    test('try plus-strnull', () async {
      expect(await deepDao.plusString('null'), equals(0));
    });

    test('try plus-IN', () async {
      expect(await deepDao.plusString('IN'), equals(0));
    });

    test('try plus-abc', () async {
      expect(await deepDao.plusString('abc'), equals(0));
    });
  });
}

@Database(version: 1, entities: [Person])
abstract class TestDatabase extends FloorDatabase {
  DeepDao get deepDao;
  CaseDao get caseDao;
}

@dao
abstract class DeepDao {
  @Query('SELECT :x IN (:list)')
  Future<bool> isXinList(String x, List<String> list);

  @Query('SELECT :x + :x + :x')
  Future<int> plusString(String x);

  @insert
  Future<void> insertPerson(Person person);
}

@dao
abstract class CaseDao {
  @Query('SELECT * FROM pErson')
  Stream<List<Person>> allPersons();

  @Query('UPDATE peRson SET custom_name=\'what\' WHERE id=-3')
  Future<void> updateName();

  @insert
  Future<void> insertPerson(Person p);
}
