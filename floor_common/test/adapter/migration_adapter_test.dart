import 'package:floor_common/src/adapter/migration_adapter.dart';
import 'package:floor_common/src/migration.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_util/mocks.dart';

void main() {
  final mockDatabase = MockDatabase();

  tearDown(() {
    clearInteractions(mockDatabase);
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
    when(mockDatabase.execute(sql)).thenAnswer((_) => Future(() {}));

    await MigrationAdapter.runMigrations(
      mockDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    verify(mockDatabase.execute(sql));
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
    final future = Future(() {});
    when(mockDatabase.execute(sql1)).thenAnswer((_) => future);
    when(mockDatabase.execute(sql2)).thenAnswer((_) => future);
    when(mockDatabase.execute(sql3)).thenAnswer((_) => future);

    await MigrationAdapter.runMigrations(
      mockDatabase,
      startVersion,
      endVersion,
      migrations,
    );

    verifyInOrder([
      mockDatabase.execute(sql1),
      mockDatabase.execute(sql2),
      mockDatabase.execute(sql3),
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
          mockDatabase,
          startVersion,
          endVersion,
          migrations,
        );

    expect(actual, throwsStateError);
    verifyZeroInteractions(mockDatabase);
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
          mockDatabase,
          startVersion,
          endVersion,
          migrations,
        );

    expect(actual, throwsStateError);
    verifyZeroInteractions(mockDatabase);
  });
}
