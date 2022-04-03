import 'dart:async';

import 'package:flat_orm/flat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'dao_inheritance_test.g.dart';

void main() {
  group('dao inheritance tests', () {
    late TestDatabase database;
    late PersonDao personDao;

    setUp(() async {
      database = await $FlatTestDatabase.inMemoryDatabaseBuilder().build();
      personDao = database.personDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('use generated inherited insert function', () async {
      final person = Person(1, 'Simon');
      await personDao.insertItem(person);

      final actual = await personDao.findPersonById(person.id);

      expect(actual, equals(person));
    });
  });
}

@Database(version: 1, entities: [Person])
abstract class TestDatabase extends FlatDatabase {
  PersonDao get personDao;
}

@dao
abstract class PersonDao extends AbstractDao<Person> {
  @Query('SELECT * FROM Person WHERE id = :id')
  Future<Person?> findPersonById(int id);
}

abstract class AbstractDao<T> {
  @insert
  Future<void> insertItem(T item);
}

@entity
class Person {
  @primaryKey
  final int id;

  final String name;

  Person(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Person{id: $id, name: $name}';
  }
}
