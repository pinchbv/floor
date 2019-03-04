import 'dart:async';

import 'package:floor/src/adapter/query_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../util/mocks.dart';
import '../util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();

  const sql = 'abcd';
  final mapper = (Map<String, dynamic> row) => Person(row['id'], row['name']);

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
  });

  group('queries (no stream)', () {
    final underTest = QueryAdapter(mockDatabaseExecutor);

    group('query item', () {
      test('returns item', () async {
        final person = Person(1, 'Frank');
        final queryResult = Future(() => [
              <String, dynamic>{'id': person.id, 'name': person.name}
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.query(sql, mapper);

        expect(actual, equals(person));
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('null when query returns nothing', () async {
        final queryResult = Future(() => <Map<String, dynamic>>[]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.query(sql, mapper);

        expect(actual, isNull);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('exception because query returns multiple items', () async {
        final person = Person(1, 'Frank');
        final queryResult = Future(() => [
              <String, dynamic>{'id': person.id, 'name': person.name},
              <String, dynamic>{'id': 2, 'name': 'Peter'},
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = () => underTest.query(sql, mapper);

        expect(actual, throwsStateError);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });
    });

    group('query list', () {
      test('returns items', () async {
        final person = Person(1, 'Frank');
        final person2 = Person(2, 'Peter');
        final queryResult = Future(() => [
              <String, dynamic>{'id': person.id, 'name': person.name},
              <String, dynamic>{'id': person2.id, 'name': person2.name},
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.queryList(sql, mapper);

        expect(actual, equals([person, person2]));
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('returns emtpy list when query returns nothing', () async {
        final queryResult = Future(() => <Map<String, dynamic>>[]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.queryList(sql, mapper);

        expect(actual, isEmpty);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });
    });

    group('query no return', () {
      test('executes query', () async {
        await underTest.queryNoReturn(sql);

        verify(mockDatabaseExecutor.rawQuery(sql));
      });
    });
  });

  group('stream queries', () {
    // ignore: close_sinks
    StreamController<String> streamController;
    const entityName = 'person';

    QueryAdapter underTest;

    setUp(() {
      streamController = StreamController<String>();
      underTest = QueryAdapter(mockDatabaseExecutor, streamController);
    });

    tearDown(() {
      streamController.close();
      streamController = null;
    });

    test('query item and emit persistent item', () {
      final person = Person(1, 'Frank');
      final queryResult = Future(() => [
            <String, dynamic>{'id': person.id, 'name': person.name}
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(sql, entityName, mapper);

      expect(actual, emits(person));
    });

    test('query item and emit persistent item and new', () {
      final person = Person(1, 'Frank');
      final queryResult = Future(() => [
            <String, dynamic>{'id': person.id, 'name': person.name}
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(sql, entityName, mapper);
      streamController.add(entityName);

      expect(actual, emitsInOrder(<Person>[person, person]));
    });

    test('query items and emit persistent items', () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final queryResult = Future(() => [
            <String, dynamic>{'id': person.id, 'name': person.name},
            <String, dynamic>{'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(sql, entityName, mapper);

      expect(actual, emits([person, person2]));
    });

    test('query items and emit persistent items and new items', () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final queryResult = Future(() => [
            <String, dynamic>{'id': person.id, 'name': person.name},
            <String, dynamic>{'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(sql, entityName, mapper);
      streamController.add(entityName);

      expect(
        actual,
        emitsInOrder(<List<Person>>[
          <Person>[person, person2],
          <Person>[person, person2]
        ]),
      );
    });
  });
}
