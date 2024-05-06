import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;
import 'package:test/test.dart';

import '../../test_util/database_factory.dart';

part 'blob_test.g.dart';

void main() {
  group('BLOB tests', () {
    late TestDatabase database;
    late PersonDao personDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      personDao = database.personDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('find by Uint8List', () async {
      final person = Person(1, 'Simon', Uint8List(10));
      await personDao.insertPerson(person);

      final actual = await personDao.findPersonByPicture(person.picture);

      expect(actual, equals(person));
    });
  });
}

@entity
class Person {
  @primaryKey
  final int id;

  final String name;

  final Uint8List picture;

  Person(this.id, this.name, this.picture);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          const ListEquality<int>().equals(picture, other.picture);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ picture.hashCode;

  @override
  String toString() {
    return 'Person{id: $id, name: $name, picture: $picture}';
  }
}

@Database(version: 1, entities: [Person])
abstract class TestDatabase extends FloorDatabase {
  PersonDao get personDao;
}

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person WHERE picture = :picture')
  Future<Person?> findPersonByPicture(Uint8List picture);

  @insert
  Future<void> insertPerson(Person person);
}
