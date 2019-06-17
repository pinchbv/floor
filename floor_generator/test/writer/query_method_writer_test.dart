import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('query no return', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('DELETE FROM Person')
      Future<void> deleteAll();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<void> deleteAll() async {
        await _queryAdapter.queryNoReturn('DELETE FROM Person');
      }
    '''));
  });

  test('query no return with parameter', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('DELETE FROM Person WHERE id = :id')
      Future<void> deletePersonById(int id);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<void> deletePersonById(int id) async {
        await _queryAdapter.queryNoReturn('DELETE FROM Person WHERE id = ?', arguments: <dynamic>[id]);
      }
    '''));
  });

  test('query item', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findById(int id);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person> findById(int id) async {
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ?', arguments: <dynamic>[id], mapper: _personMapper);
      }
    '''));
  });

  test('query item multiple parameters', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
      Future<Person> findById(int id, String name);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person> findById(int id, String name) async {
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ? AND name = ?', arguments: <dynamic>[id, name], mapper: _personMapper);
      }
    '''));
  });

  test('query list', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAll();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart('''
      @override
      Future<List<Person>> findAll() async {
        return _queryAdapter.queryList('SELECT * FROM Person', mapper: _personMapper);
      }
    '''));
  });

  test('query item stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Stream<Person> findByIdAsStream(int id);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<Person> findByIdAsStream(int id) {
        return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?', arguments: <dynamic>[id], tableName: 'Person', mapper: _personMapper);
      }
    '''));
  });

  test('query list stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person')
      Stream<List<Person>> findAllAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<Person>> findAllAsStream() {
        return _queryAdapter.queryListStream('SELECT * FROM Person', tableName: 'Person', mapper: _personMapper);
      }
    '''));
  });

  test('Query with IN clause', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id IN (:ids)')
      Future<List<Person>> findWithIds(List<int> ids);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findWithIds(List<int> ids) async {
        final valueList1 = ids.map((value) => '$value').join(', ');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN ($valueList1)', mapper: _personMapper);
      }
    '''));
  });

  test('Query with multiple IN clauses', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id IN (:ids) AND id IN (:idx)')
      Future<List<Person>> findWithIds(List<int> ids, List<int> idx);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findWithIds(List<int> ids, List<int> idx) async {
        final valueList1 = ids.map((value) => '$value').join(', ');
        final valueList2 = idx.map((value) => '$value').join(', ');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN ($valueList1) AND id IN ($valueList2)', mapper: _personMapper);
      }
    '''));
  });
}

Future<QueryMethod> _createQueryMethod(final String methodSignature) async {
  final dao = await createDao(methodSignature);
  return dao.queryMethods.first;
}
