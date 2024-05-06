import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;
import 'package:test/test.dart';

import '../../test_util/database_factory.dart';

part 'autoinc_test.g.dart';

void main() {
  group('AutoIncrement tests', () {
    late TestDatabase database;
    late AIDao aiDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      aiDao = database.aiDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('first id is 1', () async {
      final obj = AutoIncEntity(1.0, id: null);
      await aiDao.insertAIEntity(obj);

      final actual = await aiDao.findWithId(1);
      expect(actual, equals(AutoIncEntity(1.0, id: 1)));
    });

    test('retrieve multiple entities', () async {
      final obj = AutoIncEntity(1.5, id: null);
      final obj2 = AutoIncEntity(1.7, id: null);
      await aiDao.insertAIEntity(obj);
      await aiDao.insertAIEntity(obj2);

      final actual = await aiDao.findAll();
      expect(actual,
          equals([AutoIncEntity(1.5, id: 1), AutoIncEntity(1.7, id: 2)]));
    });
  });
}

@entity
class AutoIncEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final double decimal;

  AutoIncEntity(this.decimal, {this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoIncEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          decimal == other.decimal;

  @override
  int get hashCode => id.hashCode ^ decimal.hashCode;

  @override
  String toString() {
    return 'AutoIncEntity{id: $id, decimal: $decimal}';
  }
}

@Database(version: 1, entities: [AutoIncEntity])
abstract class TestDatabase extends FloorDatabase {
  AIDao get aiDao;
}

@dao
abstract class AIDao {
  @Query('SELECT * FROM AutoIncEntity where id = :val')
  Future<AutoIncEntity?> findWithId(int val);

  @Query('SELECT * FROM AutoIncEntity')
  Future<List<AutoIncEntity>> findAll();

  @insert
  Future<void> insertAIEntity(AutoIncEntity e);
}
