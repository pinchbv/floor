import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;
import 'package:test/test.dart';

import '../../test_util/database_factory.dart';

part 'bool_test.g.dart';

void main() {
  group('Bool tests', () {
    late TestDatabase database;
    late BoolDao boolDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      boolDao = database.boolDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('find by nonNull true', () async {
      final obj = BooleanClass(true, nullable: false, nonNullable: true);
      await boolDao.insertBoolC(obj);

      final actual = await boolDao.findWithNonNullable(true);
      expect(actual, equals(obj));
    });

    test('find by nonNull false and convert null boolean', () async {
      final obj = BooleanClass(true, nullable: null, nonNullable: false);
      await boolDao.insertBoolC(obj);

      final actual = await boolDao.findWithNonNullable(false);
      expect(actual, equals(obj));
    });

    test('find by nullable true', () async {
      final obj = BooleanClass(true, nullable: true, nonNullable: true);
      await boolDao.insertBoolC(obj);

      final actual = await boolDao.findWithNullable(true);
      expect(actual, equals(obj));
    });

    test('find by nullable false', () async {
      final obj = BooleanClass(true, nullable: false, nonNullable: true);
      await boolDao.insertBoolC(obj);

      final actual = await boolDao.findWithNullable(false);
      expect(actual, equals(obj));
    });
  });
}

@entity
class BooleanClass {
  @primaryKey
  final bool? id;

  final bool? nullable;

  final bool nonNullable;

  BooleanClass(this.id, {this.nullable, required this.nonNullable});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanClass &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nullable == other.nullable &&
          nonNullable == other.nonNullable;

  @override
  int get hashCode => id.hashCode ^ nullable.hashCode ^ nonNullable.hashCode;

  @override
  String toString() {
    return 'BooleanClass{id: $id, nullable: $nullable, nonNullable: $nonNullable}';
  }
}

@Database(version: 1, entities: [BooleanClass])
abstract class TestDatabase extends FloorDatabase {
  BoolDao get boolDao;
}

@dao
abstract class BoolDao {
  @Query('SELECT * FROM BooleanClass where nonNullable = :val')
  Future<BooleanClass?> findWithNonNullable(bool val);

  @Query('SELECT * FROM BooleanClass where nullable = :val')
  Future<BooleanClass?> findWithNullable(bool val);

  @Query('SELECT * FROM BooleanClass where nullable IS NULL')
  Future<BooleanClass?> findWithNullableBeingNull();

  @insert
  Future<void> insertBoolC(BooleanClass person);
}
