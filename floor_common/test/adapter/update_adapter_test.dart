import 'package:floor_common/floor_common.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:test/test.dart';

import '../test_util/mocks.dart';
import '../test_util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();
  final mockDatabaseBatch = MockBatch();

  const entityName = 'person';
  const primaryKeyColumnName = 'id';
  final valueMapper = (Person person) => {'id': person.id, 'name': person.name};
  const onConflictStrategy = OnConflictStrategy.ignore;
  const conflictAlgorithm = ConflictAlgorithm.ignore;

  final underTest = UpdateAdapter(
    mockDatabaseExecutor,
    entityName,
    [primaryKeyColumnName],
    valueMapper,
  );

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
    clearInteractions(mockDatabaseBatch);
    reset(mockDatabaseExecutor);
    reset(mockDatabaseBatch);
  });

  group('update without return', () {
    test('update item', () async {
      final person = Person(1, 'Simon');
      final values = {'id': person.id, 'name': person.name};
      when(mockDatabaseExecutor.update(
        entityName,
        values,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => 1));

      await underTest.update(person, onConflictStrategy);

      verify(mockDatabaseExecutor.update(
        entityName,
        values,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
        conflictAlgorithm: conflictAlgorithm,
      ));
    });

    test('update items', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => <int>[1, 1]));

      await underTest.updateList(persons, onConflictStrategy);

      final values1 = {'id': person1.id, 'name': person1.name};
      final values2 = {'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.update(
          entityName,
          values1,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person1.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.update(
          entityName,
          values2,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person2.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
    });

    test('update items but supply empty list', () async {
      await underTest.updateList([], onConflictStrategy);

      verifyZeroInteractions(mockDatabaseExecutor);
    });
  });

  group('update with return', () {
    test('update item and return changed rows (1)', () async {
      final person = Person(1, 'Simon');
      final values = {'id': person.id, 'name': person.name};
      when(mockDatabaseExecutor.update(
        entityName,
        values,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => 1));

      final actual = await underTest.updateAndReturnChangedRows(
        person,
        onConflictStrategy,
      );

      verify(mockDatabaseExecutor.update(
        entityName,
        values,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
        conflictAlgorithm: conflictAlgorithm,
      ));
      expect(actual, equals(1));
    });

    test('update items and return changed rows', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => <int>[1, 1]));

      final actual = await underTest.updateListAndReturnChangedRows(
        persons,
        onConflictStrategy,
      );

      final values1 = {'id': person1.id, 'name': person1.name};
      final values2 = {'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.update(
          entityName,
          values1,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person1.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.update(
          entityName,
          values2,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person2.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
      expect(actual, equals(2));
    });

    test('update items but supply empty list', () async {
      final actual = await underTest
          .updateListAndReturnChangedRows([], onConflictStrategy);

      verifyZeroInteractions(mockDatabaseExecutor);
      expect(actual, equals(0));
    });
  });
}
