import 'package:floor/src/database.dart';
import 'package:floor/src/migration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

void main() {
  final floorDatabase = TestFloorDatabase();
  final mockMigrationDatabase = MockSqfliteDatabase();

  tearDown(() {
    clearInteractions(mockMigrationDatabase);
  });

  test('run single migration', () {
    const startVersion = 1;
    const endVersion = 2;
    const sql = 'FOO BAR';
    final migrations = [
      Migration(1, 2, (database) {
        database.execute(sql);
      })
    ];

    // ignore: invalid_use_of_protected_member
    floorDatabase.runMigrations(
      mockMigrationDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    verify(mockMigrationDatabase.execute(sql));
  });

  test('run multiple migrations in order', () {
    const startVersion = 1;
    const endVersion = 4;
    const sql1 = 'first';
    const sql2 = 'second';
    const sql3 = 'third';
    final migrations = [
      Migration(3, 4, (database) {
        database.execute(sql3);
      }),
      Migration(1, 2, (database) {
        database.execute(sql1);
      }),
      Migration(2, 3, (database) {
        database.execute(sql2);
      }),
    ];

    // ignore: invalid_use_of_protected_member
    floorDatabase.runMigrations(
      mockMigrationDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    verifyInOrder([
      mockMigrationDatabase.execute(sql1),
      mockMigrationDatabase.execute(sql2),
      mockMigrationDatabase.execute(sql3),
    ]);
  });

  test('exception when no matching start version found', () {
    const startVersion = 10;
    const endVersion = 20;
    const sql = 'FOO BAR';
    final migrations = [
      Migration(1, 2, (database) {
        database.execute(sql);
      })
    ];

    // ignore: invalid_use_of_protected_member
    final actual = () => floorDatabase.runMigrations(
          mockMigrationDatabase,
          startVersion,
          endVersion,
          migrations,
        );

    expect(actual, throwsStateError);
    verifyZeroInteractions(mockMigrationDatabase);
  });

  test('exception when no matching end version found', () {
    const startVersion = 1;
    const endVersion = 10;
    const sql = 'FOO BAR';
    final migrations = [
      Migration(1, 2, (database) {
        database.execute(sql);
      })
    ];

    // ignore: invalid_use_of_protected_member
    final actual = () => floorDatabase.runMigrations(
      mockMigrationDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    expect(actual, throwsStateError);
    verifyZeroInteractions(mockMigrationDatabase);
  });
}

class TestFloorDatabase extends FloorDatabase {
  @override
  Future<Database> open(List<Migration> migrations) {
    return null;
  }
}

class MockSqfliteDatabase extends Mock implements Database {}
