// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor/floor.dart';
import 'package:floor/src/adapter/insertion_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../test_util/mocks.dart';
import '../test_util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();
  final mockDatabaseBatch = MockDatabaseBatch();

  const entityName = 'person';
  final valueMapper =
      (Person person) => <String, Object>{'id': person.id, 'name': person.name};
  const onConflictStrategy = OnConflictStrategy.ignore;
  const conflictAlgorithm = ConflictAlgorithm.ignore;

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
    clearInteractions(mockDatabaseBatch);
    reset(mockDatabaseExecutor);
    reset(mockDatabaseBatch);
  });

  group('insertion without stream listening', () {
    final underTest = InsertionAdapter(
      mockDatabaseExecutor,
      entityName,
      valueMapper,
    );

    group('insertion without return', () {
      test('insert item', () async {
        final person = Person(1, 'Simon');

        await underTest.insert(person, onConflictStrategy);

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

        await underTest.insertList(persons, onConflictStrategy);

        final values1 = <String, dynamic>{
          'id': person1.id,
          'name': person1.name
        };
        final values2 = <String, dynamic>{
          'id': person2.id,
          'name': person2.name
        };
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
        await underTest.insertList([], onConflictStrategy);

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
            await underTest.insertAndReturnId(person, onConflictStrategy);

        verify(mockDatabaseExecutor.insert(
          entityName,
          values,
          conflictAlgorithm: conflictAlgorithm,
        ));
        expect(actual, equals(person.id));
      });

      test('insert item but transaction failed (return 0)', () async {
        final person = Person(1, 'Simon');
        final values = <String, dynamic>{'id': person.id, 'name': person.name};
        when(mockDatabaseExecutor.insert(
          entityName,
          values,
          conflictAlgorithm: conflictAlgorithm,
        )).thenAnswer((_) => Future(() => 0));

        final actual =
            await underTest.insertAndReturnId(person, onConflictStrategy);

        verify(mockDatabaseExecutor.insert(
          entityName,
          values,
          conflictAlgorithm: conflictAlgorithm,
        ));
        expect(actual, equals(0));
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
            await underTest.insertListAndReturnIds(persons, onConflictStrategy);

        final values1 = <String, dynamic>{
          'id': person1.id,
          'name': person1.name
        };
        final values2 = <String, dynamic>{
          'id': person2.id,
          'name': person2.name
        };
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
            await underTest.insertListAndReturnIds([], onConflictStrategy);

        verifyZeroInteractions(mockDatabaseExecutor);
        expect(actual, equals(<int>[]));
      });
    });
  });

  group('insertion while stream is listening', () {
    // ignore: close_sinks
    final mockStreamController = MockStreamController<String>();

    final underTest = InsertionAdapter(
      mockDatabaseExecutor,
      entityName,
      valueMapper,
      mockStreamController,
    );

    tearDown(() {
      clearInteractions(mockStreamController);
      reset(mockStreamController);
    });

    test('insert item', () async {
      final person = Person(1, 'Simon');
      when(mockDatabaseExecutor.insert(
        entityName,
        valueMapper(person),
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => person.id));

      await underTest.insert(person, onConflictStrategy);

      verify(mockStreamController.add(entityName));
    });

    test('insert item but transaction failed (returns 0)', () async {
      final person = Person(1, 'Simon');
      when(mockDatabaseExecutor.insert(
        entityName,
        valueMapper(person),
        conflictAlgorithm: conflictAlgorithm,
      )).thenAnswer((_) => Future(() => 0));

      await underTest.insert(person, onConflictStrategy);

      verifyZeroInteractions(mockStreamController);
    });

    test('insert list', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      final primaryKeys = persons.map((person) => person.id).toList();
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => primaryKeys));

      await underTest.insertList(persons, onConflictStrategy);

      verify(mockStreamController.add(entityName));
    });

    test('insert empty list', () async {
      await underTest.insertList([], onConflictStrategy);

      verifyZeroInteractions(mockStreamController);
    });
  });
}
