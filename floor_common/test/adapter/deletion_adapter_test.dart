import 'package:floor_common/src/adapter/deletion_adapter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_util/mocks.dart';
import '../test_util/person.dart';

void main() {
  final mockDatabaseExecutor = MockDatabaseExecutor();
  final mockDatabaseBatch = MockBatch();

  const entityName = 'person';
  const primaryKeyColumnName = 'id';
  final valueMapper = (Person person) => {'id': person.id, 'name': person.name};

  final underTest = DeletionAdapter(
    mockDatabaseExecutor,
    entityName,
    [primaryKeyColumnName],
    valueMapper,
  );

  tearDown(() {
    clearInteractions(mockDatabaseExecutor);
  });

  group('delete without return', () {
    test('delete item', () async {
      final person = Person(1, 'Simon');
      when(mockDatabaseExecutor.delete(
        entityName,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
      )).thenAnswer((_) => Future(() => 1));

      await underTest.delete(person);

      verify(mockDatabaseExecutor.delete(
        entityName,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
      ));
    });

    test('delete list', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => <int>[1, 1]));

      await underTest.deleteList(persons);

      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.delete(
          entityName,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person1.id],
        ),
        mockDatabaseBatch.delete(
          entityName,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person2.id],
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
    });

    test('delete list but supply empty list', () async {
      await underTest.deleteList([]);

      verifyZeroInteractions(mockDatabaseExecutor);
    });
  });

  group('delete with return', () {
    test('delete item and return changed rows (1)', () async {
      final person = Person(1, 'Simon');
      when(mockDatabaseExecutor.delete(
        entityName,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
      )).thenAnswer((_) => Future(() => 1));

      final actual = await underTest.deleteAndReturnChangedRows(person);

      verify(mockDatabaseExecutor.delete(
        entityName,
        where: '$primaryKeyColumnName = ?',
        whereArgs: [person.id],
      ));
      expect(actual, equals(1));
    });

    test('delete items and return changed rows', () async {
      final person1 = Person(1, 'Simon');
      final person2 = Person(2, 'Frank');
      final persons = [person1, person2];
      when(mockDatabaseExecutor.batch()).thenReturn(mockDatabaseBatch);
      when(mockDatabaseBatch.commit(noResult: false))
          .thenAnswer((_) => Future(() => <int>[1, 1]));

      final actual = await underTest.deleteListAndReturnChangedRows(persons);

      verifyInOrder([
        mockDatabaseExecutor.batch(),
        mockDatabaseBatch.delete(
          entityName,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person1.id],
        ),
        mockDatabaseBatch.delete(
          entityName,
          where: '$primaryKeyColumnName = ?',
          whereArgs: [person2.id],
        ),
        mockDatabaseBatch.commit(noResult: false),
      ]);
      expect(actual, equals(2));
    });

    test('delete items but supply empty list', () async {
      final actual = await underTest.deleteListAndReturnChangedRows([]);

      verifyZeroInteractions(mockDatabaseExecutor);
      expect(actual, equals(0));
    });
  });
}
