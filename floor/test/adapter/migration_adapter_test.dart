// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor/src/adapter/migration_adapter.dart';
import 'package:floor/src/migration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../test_util/mocks.dart';

void main() {
  final mockMigrationDatabase = MockSqfliteDatabase();

  tearDown(() {
    clearInteractions(mockMigrationDatabase);
  });

  test('run single migration', () async {
    const startVersion = 1;
    const endVersion = 2;
    const sql = 'FOO BAR';
    final migrations = [
      Migration(1, 2, (database) async {
        await database.execute(sql);
      })
    ];

    await MigrationAdapter.runMigrations(
      mockMigrationDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    verify(mockMigrationDatabase.execute(sql));
  });

  test('run multiple migrations in order', () async {
    const startVersion = 1;
    const endVersion = 4;
    const sql1 = 'first';
    const sql2 = 'second';
    const sql3 = 'third';
    final migrations = [
      Migration(3, 4, (database) async {
        await database.execute(sql3);
      }),
      Migration(1, 2, (database) async {
        await database.execute(sql1);
      }),
      Migration(2, 3, (database) async {
        await database.execute(sql2);
      }),
    ];

    await MigrationAdapter.runMigrations(
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
      Migration(1, 2, (database) async {
        await database.execute(sql);
      })
    ];

    final actual = () => MigrationAdapter.runMigrations(
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
      Migration(1, 2, (database) async {
        await database.execute(sql);
      })
    ];

    final actual = () => MigrationAdapter.runMigrations(
          mockMigrationDatabase,
          startVersion,
          endVersion,
          migrations,
        );

    expect(actual, throwsStateError);
    verifyZeroInteractions(mockMigrationDatabase);
  });
}
