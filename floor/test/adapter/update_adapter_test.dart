import 'package:floor/src/adapter/update_adapter.dart';
import 'package:floor/src/util/query_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../util/mocks.dart';
import '../util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();
  final mockDatabaseBatch = MockDatabaseBatch();

  const entityName = 'person';
  const primaryKeyColumnName = ['id'];
  final valueMapper = (Person person) =>
      <String, dynamic>{'id': person.id, 'name': person.name};
  const conflictAlgorithm = ConflictAlgorithm.abort;

  final underTest = UpdateAdapter(
    mockDatabaseExecutor,
    entityName,
    primaryKeyColumnName,
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

      await underTest.update(person, conflictAlgorithm);

      final values = <String, dynamic>{'id': person.id, 'name': person.name};
      verify(mockDatabaseExecutor.update(
        entityName,
        values,
        where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
        whereArgs: <dynamic>[person.id],
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

      await underTest.updateList(persons, conflictAlgorithm);

      final values1 = <String, dynamic>{'id': person1.id, 'name': person1.name};
      final values2 = <String, dynamic>{'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.update(
          entityName,
          values1,
          where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
          whereArgs: <dynamic>[person1.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.update(
          entityName,
          values2,
          where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
          whereArgs: <dynamic>[person2.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
    });

    test('update items but supply empty list', () async {
      await underTest.updateList([], conflictAlgorithm);

      verifyZeroInteractions(mockDatabaseExecutor);
    });
  });

  group('update with return', () {
    test('update item and return changed rows (1)', () async {
      final person = Person(1, 'Simon');
      final values = <String, dynamic>{'id': person.id, 'name': person.name};
      when(mockDatabaseExecutor.update(
        entityName,
        values,
        where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
        whereArgs: <dynamic>[person.id],
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => 1));

      final actual =
          await underTest.updateAndReturnChangedRows(person, conflictAlgorithm);

      verify(mockDatabaseExecutor.update(
        entityName,
        values,
        where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
        whereArgs: <dynamic>[person.id],
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
          persons, conflictAlgorithm);

      final values1 = <String, dynamic>{'id': person1.id, 'name': person1.name};
      final values2 = <String, dynamic>{'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.update(
          entityName,
          values1,
          where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
          whereArgs: <dynamic>[person1.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.update(
          entityName,
          values2,
          where: QueryFormatter.getGroupPrimaryKeyQuery(primaryKeyColumnName),
          whereArgs: <dynamic>[person2.id],
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
      expect(actual, equals(2));
    });

    test('update items but supply empty list', () async {
      final actual =
          await underTest.updateListAndReturnChangedRows([], conflictAlgorithm);

      verifyZeroInteractions(mockDatabaseExecutor);
      expect(actual, equals(0));
    });
  });
}
