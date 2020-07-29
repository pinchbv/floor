import 'dart:async';

import 'package:floor/floor.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../model/person.dart';

part 'sqlparser_test.g.dart';

void main() {
  group('BLOB tests', () {
    TestDatabase database;
    DeepDao deepDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      deepDao = database.deepDao;
    });

    tearDown(() async {
      await database.close();
    });

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
