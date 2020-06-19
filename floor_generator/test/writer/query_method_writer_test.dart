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
        await _queryAdapter
            .queryNoReturn(r""" DELETE FROM Person """, changedEntities: {'Person'});
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
        await _queryAdapter.queryNoReturn(r""" DELETE FROM Person WHERE id = ?1 """,
            arguments: <dynamic>[id], changedEntities: {'Person'});
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
        return _queryAdapter.query(r""" SELECT * FROM Person WHERE id = ?1 """,
            mapper: _personMapper, arguments: <dynamic>[id]);
      }
    '''));
  });

  test('query boolean parameter', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE (name = name) = :flag')
      Future<List<Person>> findWithFlag(bool flag);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findWithFlag(bool flag) async {
        return _queryAdapter.queryList(r""" SELECT * FROM Person WHERE (name = name) = ?1 """, mapper: _personMapper, arguments: <dynamic>[flag == null ? null : (flag ? 1 : 0)]);
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
        return _queryAdapter.query(r""" SELECT * FROM Person WHERE id = ?1 AND name = ?2 """, mapper: _personMapper, arguments: <dynamic>[id, name]);
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
        return _queryAdapter.queryList(r""" SELECT * FROM Person """, mapper: _personMapper);
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
        return _queryAdapter.queryStream(r""" SELECT * FROM Person WHERE id = ?1 """, mapper: _personMapper, arguments: <dynamic>[id], dependencies: {'Person'});
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
        return _queryAdapter.queryListStream(r""" SELECT * FROM Person """, mapper: _personMapper, dependencies: {'Person'});
      }
    '''));
  });

  test('query list stream from view', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Name')
      Stream<List<Name>> findAllAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<Name>> findAllAsStream() {
        return _queryAdapter.queryListStream(r""" SELECT * FROM Name """, mapper: _nameMapper, dependencies: {'Person'});
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
        int _start = 1;
        final _sqliteVariablesForIds =
            Iterable<String>.generate(ids.length, (i) => '?${i + _start}')
                .join(',');
        return _queryAdapter.queryList(
            r""" SELECT * FROM Person WHERE id IN ( """ +
                _sqliteVariablesForIds +
                r""" ) """,
            mapper: _personMapper,
            arguments: <dynamic>[...ids]);
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
        int _start = 1;
        final _sqliteVariablesForIds =
            Iterable<String>.generate(ids.length, (i) => '?${i + _start}').join(',');
        _start += ids.length;
        final _sqliteVariablesForIdx =
            Iterable<String>.generate(idx.length, (i) => '?${i + _start}').join(',');
        return _queryAdapter.queryList(
        r""" SELECT * FROM Person WHERE id IN ( """ +
                _sqliteVariablesForIds +
                r""" ) AND id IN ( """ +
                _sqliteVariablesForIdx +
                r""" ) """,
            mapper: _personMapper,
            arguments: <dynamic>[...ids,...idx]);
      }
    '''));
  });

  test('Query with \' characters', () async {
    final queryMethod = await _createQueryMethod(r'''
      @Query('SELECT * FROM Person WHERE name = \'\'')
      Future<List<Person>> findEmptyNames();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findEmptyNames() async {
        return _queryAdapter.queryList(r""" SELECT * FROM Person WHERE name = '' """, mapper: _personMapper);
      }
    '''));
  });

  test('Query with \" characters', () async {
    final queryMethod = await _createQueryMethod(r'''
      @Query('SELECT * FROM Person WHERE "name" = \'\'')
      Future<List<Person>> findEmptyNames();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findEmptyNames() async {
        return _queryAdapter.queryList(r""" SELECT * FROM Person WHERE "name" = '' """, mapper: _personMapper);
      }
    '''));
  });

  test('Query with ` characters', () async {
    final queryMethod = await _createQueryMethod(r'''
      @Query('SELECT * FROM Person WHERE `name` = \'\'')
      Future<List<Person>> findEmptyNames();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findEmptyNames() async {
        return _queryAdapter.queryList(r""" SELECT * FROM Person WHERE `name` = '' """, mapper: _personMapper);
      }
    '''));
  });

  //TODO maybe move this to processor test
/*  test('query with unsupported type throws', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person> findById(Person person);
    ''');

    final actual = () => QueryMethodWriter(queryMethod).write();

    expect(actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
  });*/
}

Future<QueryMethod> _createQueryMethod(final String methodSignature) async {
  final dao = await createDao(methodSignature);
  return dao.queryMethods.first;
}
