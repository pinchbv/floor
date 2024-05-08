import 'dart:async';

import 'package:floor_common/src/adapter/query_adapter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_util/mocks.dart';
import '../test_util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();

  const sql = 'SELECT * FROM dbName';
  final mapper = (Map<String, Object?> row) =>
      Person(row['id'] as int, row['name'] as String);

  final intResultMapper = (Map<String, Object?> row) => row.values.first as int;

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
  });

  group('queries (no stream)', () {
    final underTest = QueryAdapter(mockDatabaseExecutor);

    group('query item', () {
      test('returns item without arguments', () async {
        final person = Person(1, 'Frank');
        final queryResult = Future(() => [
              {'id': person.id, 'name': person.name}
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.query(sql, mapper: mapper);

        expect(actual, equals(person));
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('returns item with arguments', () async {
        final person = Person(1, 'Frank');
        final arguments = [person.id, person.name];
        final queryResult = Future(() => [
              {'id': person.id, 'name': person.name}
            ]);
        when(mockDatabaseExecutor.rawQuery(sql, arguments))
            .thenAnswer((_) => queryResult);

        final actual =
            await underTest.query(sql, arguments: arguments, mapper: mapper);

        expect(actual, equals(person));
        verify(mockDatabaseExecutor.rawQuery(sql, arguments));
      });

      test('null when query returns nothing', () async {
        final queryResult = Future(() => <Map<String, Object?>>[]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.query(sql, mapper: mapper);

        expect(actual, isNull);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('exception because query returns multiple items', () async {
        final person = Person(1, 'Frank');
        final queryResult = Future(() => [
              {'id': person.id, 'name': person.name},
              {'id': 2, 'name': 'Peter'},
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = () => underTest.query(sql, mapper: mapper);

        expect(actual, throwsStateError);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });
    });

    group('query list', () {
      test('returns items without arguments', () async {
        final person = Person(1, 'Frank');
        final person2 = Person(2, 'Peter');
        final queryResult = Future(() => [
              {'id': person.id, 'name': person.name},
              {'id': person2.id, 'name': person2.name},
            ]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.queryList(sql, mapper: mapper);

        expect(actual, equals([person, person2]));
        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('returns items with arguments', () async {
        final person = Person(1, 'Frank');
        final person2 = Person(2, 'Peter');
        final arguments = [person.id, person2.id];
        final queryResult = Future(() => [
              {'id': person.id, 'name': person.name},
              {'id': person2.id, 'name': person2.name},
            ]);
        when(mockDatabaseExecutor.rawQuery(sql, arguments))
            .thenAnswer((_) => queryResult);

        final actual = await underTest.queryList(sql,
            arguments: arguments, mapper: mapper);

        expect(actual, equals([person, person2]));
        verify(mockDatabaseExecutor.rawQuery(sql, arguments));
      });

      test('returns empty list when query returns nothing', () async {
        final queryResult = Future(() => <Map<String, Object?>>[]);
        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

        final actual = await underTest.queryList(sql, mapper: mapper);

        expect(actual, isEmpty);
        verify(mockDatabaseExecutor.rawQuery(sql));
      });
    });

    group('query no return', () {
      test('executes query', () async {
        await underTest.queryNoReturn(sql);

        verify(mockDatabaseExecutor.rawQuery(sql));
      });

      test('executes query with argument', () async {
        final arguments = [123];
        final queryResult = Future(() => <Map<String, Object?>>[]);
        when(mockDatabaseExecutor.rawQuery(sql, arguments))
            .thenAnswer((_) => queryResult);

        await underTest.queryNoReturn(sql, arguments: arguments);

        verify(mockDatabaseExecutor.rawQuery(sql, arguments));
      });
    });

    group('query update', () {
      final arguments = [1, 'Nick'];
      const updateSQL = 'UPDATE OR ABORT Person SET id = ?, name = ?';

      test('executes query update returns rows tick', () async {
        when(mockDatabaseExecutor.rawUpdate(
          updateSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        final actual = await underTest.query(
          updateSQL,
          arguments: arguments,
          mapper: intResultMapper,
        );

        expect(actual, equals(1));
        verify(mockDatabaseExecutor.rawUpdate(updateSQL, arguments));
      });

      test('executes query update with arguments no return', () async {
        when(mockDatabaseExecutor.rawUpdate(
          updateSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        await underTest.queryNoReturn(updateSQL, arguments: arguments);

        verify(mockDatabaseExecutor.rawUpdate(updateSQL, arguments));
      });

      test('throws error when update query returns List', () async {
        final queryList = () => underTest.queryList(
              updateSQL,
              arguments: arguments,
              mapper: intResultMapper,
            );

        expect(queryList, throwsA(const TypeMatcher<StateError>()));
      });
    });

    group('query insert', () {
      const arguments = [1, 'Frank'];
      const insertSQL = 'INSERT OR ABORT INTO Person (id, name) VALUES (?, ?)';

      test('executes query insert with arguments returns rows tick', () async {
        when(mockDatabaseExecutor.rawInsert(
          insertSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        final actual = await underTest.query(
          insertSQL,
          arguments: arguments,
          mapper: intResultMapper,
        );

        expect(actual, equals(1));
        verify(mockDatabaseExecutor.rawInsert(insertSQL, arguments));
      });

      test('executes query insert with arguments no return', () async {
        when(mockDatabaseExecutor.rawInsert(
          insertSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        await underTest.queryNoReturn(insertSQL, arguments: arguments);

        verify(mockDatabaseExecutor.rawInsert(insertSQL, arguments));
      });

      test('throws error when insert query returns List', () async {
        final queryList = () => underTest.queryList(
              insertSQL,
              arguments: arguments,
              mapper: intResultMapper,
            );

        expect(queryList, throwsA(const TypeMatcher<StateError>()));
      });
    });

    group('query delete', () {
      const arguments = [1];
      const deleteSQL = 'DELETE FROM Person WHERE id = ?';

      test('executes query delete with arguments returns rows tick', () async {
        when(mockDatabaseExecutor.rawDelete(
          deleteSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        final actual = await underTest.query(
          deleteSQL,
          arguments: arguments,
          mapper: intResultMapper,
        );

        expect(actual, equals(1));
        verify(mockDatabaseExecutor.rawDelete(deleteSQL, arguments));
      });

      test('executes query delete with arguments no return', () async {
        when(mockDatabaseExecutor.rawDelete(
          deleteSQL,
          arguments,
        )).thenAnswer((_) => Future.value(1));

        await underTest.queryNoReturn(deleteSQL, arguments: arguments);

        verify(mockDatabaseExecutor.rawDelete(deleteSQL, arguments));
      });

      test('throws error when delete query returns List', () async {
        final queryList = () => underTest.queryList(
              deleteSQL,
              arguments: arguments,
              mapper: intResultMapper,
            );

        expect(queryList, throwsA(const TypeMatcher<StateError>()));
      });
    });
  });

  group('stream queries', () {
    // ignore: close_sinks
    StreamController<String>? streamController;
    const entityName = 'person';

    late QueryAdapter underTest;

    setUp(() {
      streamController = StreamController<String>();
      underTest = QueryAdapter(mockDatabaseExecutor, streamController);
    });

    tearDown(() {
      streamController!.close();
      streamController = null;
    });

    test('query item and emit persistent item without arguments', () {
      final person = Person(1, 'Frank');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name}
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(sql,
          queryableName: entityName, isView: false, mapper: mapper);

      expect(actual, emits(person));
    });

    test('query item and emit persistent item with arguments', () {
      final person = Person(1, 'Frank');
      final arguments = [person.id, person.name];
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name}
          ]);
      when(mockDatabaseExecutor.rawQuery(sql, arguments))
          .thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(
        sql,
        arguments: arguments,
        queryableName: entityName,
        isView: false,
        mapper: mapper,
      );

      expect(actual, emits(person));
    });

    test('query item and emit persistent item and new', () {
      final person = Person(1, 'Frank');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name}
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(sql,
          queryableName: entityName, isView: false, mapper: mapper);
      streamController!.add(entityName);

      expect(actual, emitsInOrder(<Person>[person, person]));
    });

    test('query item emits null when query has no result', () {
      final queryResult = Future(() => <Map<String, Object?>>[]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryStream(sql,
          queryableName: entityName, isView: false, mapper: mapper);

      expect(actual, emits(null));
    });

    test('query items and emit persistent items without arguments', () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name},
            {'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(sql,
          queryableName: entityName, isView: false, mapper: mapper);

      expect(actual, emits([person, person2]));
    });

    test('query items and emit persistent items with arguments', () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final arguments = [person.id, person2.id];
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name},
            {'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql, arguments))
          .thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(
        sql,
        arguments: arguments,
        queryableName: entityName,
        isView: false,
        mapper: mapper,
      );

      expect(actual, emits([person, person2]));
    });

    test('query items and emit persistent items and new items', () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name},
            {'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(sql,
          queryableName: entityName, isView: false, mapper: mapper);
      streamController!.add(entityName);

      expect(
        actual,
        emitsInOrder(<List<Person>>[
          <Person>[person, person2],
          <Person>[person, person2]
        ]),
      );
    });

    test('query stream from view with same and different triggering entity',
        () async {
      final person = Person(1, 'Frank');
      final person2 = Person(2, 'Peter');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name},
            {'id': person2.id, 'name': person2.name},
          ]);
      when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) => queryResult);

      final actual = underTest.queryListStream(sql,
          queryableName: entityName, isView: true, mapper: mapper);
      expect(
        actual,
        emitsInOrder(<List<Person>>[
          <Person>[person, person2],
          <Person>[person, person2],
          <Person>[person, person2]
        ]),
      );

      streamController!.add(entityName);
      streamController!.add('otherEntity');
    });

    group('non select query', () {
      final person = Person(1, 'Frank');
      final newPerson = Person(1, 'Nick');
      final queryResult = Future(() => [
            {'id': person.id, 'name': person.name}
          ]);
      final newQueryResult = Future(() => [
            {'id': newPerson.id, 'name': newPerson.name}
          ]);

      test('query item and emit persistent item and new on update', () async {
        final arguments = [newPerson.id, newPerson.name];
        const updateSQL = 'UPDATE OR ABORT Person SET name = ? WHERE id = ?';
        int tick = 0;

        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) {
          final result = tick == 0 ? queryResult : newQueryResult;
          tick++;
          return result;
        });

        when(mockDatabaseExecutor.rawUpdate(
          updateSQL,
          arguments,
        )).thenAnswer((_) => Future(() => 1));

        final actual = underTest.queryStream(
          sql,
          queryableName: entityName,
          isView: false,
          mapper: mapper,
        );

        await underTest.queryNoReturn(updateSQL, arguments: arguments);

        expect(actual, emitsInOrder(<Person>[person, newPerson]));
      });

      test('query item and emit persistent item and new on insert', () async {
        final arguments = [newPerson.id, newPerson.name];
        const insertSQL =
            'INSERT OR ABORT INTO Person (id, name) VALUES (?, ?)';
        int tick = 0;

        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) {
          final result = tick == 0 ? queryResult : newQueryResult;
          tick++;
          return result;
        });

        when(mockDatabaseExecutor.rawInsert(
          insertSQL,
          arguments,
        )).thenAnswer((_) => Future(() => 1));

        final actual = underTest.queryStream(
          sql,
          queryableName: entityName,
          isView: false,
          mapper: mapper,
        );

        await underTest.queryNoReturn(insertSQL, arguments: arguments);

        expect(actual, emitsInOrder(<Person>[person, newPerson]));
      });

      test('query item and emit persistent item and new on delete', () async {
        final emptyQueryResult = Future(() => <Map<String, Object?>>[]);
        final arguments = [person.id];
        const deleteSQL = 'DELETE FROM Person WHERE id = ?';
        int tick = 0;

        when(mockDatabaseExecutor.rawQuery(sql)).thenAnswer((_) {
          final result = tick == 0 ? queryResult : emptyQueryResult;
          tick++;
          return result;
        });

        when(mockDatabaseExecutor.rawDelete(
          deleteSQL,
          arguments,
        )).thenAnswer((_) => Future(() => 1));

        final actual = underTest.queryStream(
          sql,
          queryableName: entityName,
          isView: false,
          mapper: mapper,
        );

        await underTest.queryNoReturn(deleteSQL, arguments: arguments);

        expect(actual, emitsInOrder(<Person?>[person, null]));
      });
    });
  });
}
