import 'package:floor/src/adapter/insertion_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../util/mocks.dart';
import '../util/person.dart';


void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();
  final mockDatabaseBatch = MockDatabaseBatch();

  const entityName = 'person';
  final valueMapper = (Person person) =>
      <String, dynamic>{'id': person.id, 'name': person.name};
  const conflictAlgorithm = ConflictAlgorithm.ignore;

  final underTest = InsertionAdapter(
    mockDatabaseExecutor,
    entityName,
    valueMapper,
  );

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
  });

  group('insertion without return', () {
    test('insert item', () async {
      final person = Person(1, 'Simon');

      await underTest.insert(person, conflictAlgorithm);

      final values = <String, dynamic>{'id': person.id, 'name': person.name};
      verify(mockDatabaseExecutor.insert(
        entityName,
        values,
        conflictAlgorithm: conflictAlgorithm,
      ));
    });

    test('insert list', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);

      await underTest.insertList(persons, conflictAlgorithm);

      final values1 = <String, dynamic>{'id': person1.id, 'name': person1.name};
      final values2 = <String, dynamic>{'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.insert(
          entityName,
          values1,
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.insert(
          entityName,
          values2,
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: true),
      ]);
    });

    test('insert empty list', () async {
      await underTest.insertList([], conflictAlgorithm);

      verifyZeroInteractions(mockDatabaseExecutor);
    });
  });

  group('insertion with return', () {
    test('insert item and return primary key', () async {
      final person = Person(1, 'Simon');
      final values = <String, dynamic>{'id': person.id, 'name': person.name};
      when(mockDatabaseExecutor.insert(
        entityName,
        values,
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => person.id));

      final actual =
          await underTest.insertAndReturnId(person, conflictAlgorithm);

      verify(mockDatabaseExecutor.insert(
        entityName,
        values,
        conflictAlgorithm: conflictAlgorithm,
      ));
      expect(actual, equals(person.id));
    });

    test('insert items and return primary keys', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      final primaryKeys = persons.map((person) => person.id).toList();
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => primaryKeys));

      final actual =
          await underTest.insertListAndReturnIds(persons, conflictAlgorithm);

      final values1 = <String, dynamic>{'id': person1.id, 'name': person1.name};
      final values2 = <String, dynamic>{'id': person2.id, 'name': person2.name};
      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.insert(
          entityName,
          values1,
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.insert(
          entityName,
          values2,
          conflictAlgorithm: conflictAlgorithm,
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
      expect(actual, equals(primaryKeys));
    });

    test('insert empty list', () async {
      final actual =
          await underTest.insertListAndReturnIds([], conflictAlgorithm);

      verifyZeroInteractions(mockDatabaseExecutor);
      expect(actual, equals(<int>[]));
    });
  });
}
