import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../dart_type.dart';
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
        await _queryAdapter.queryNoReturn('DELETE FROM Person WHERE id = ?1', arguments: [id]);
      }
    '''));
  });

  test('query item', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person?> findById(int id);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person?> findById(int id) async {
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ?1', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List), arguments: [id]);
      }
    '''));
  });

  test('query return int type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT COUNT(id) FROM Person')
      Future<int?> getUnique();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<int?> getUnique() async {
        return _queryAdapter.query('SELECT COUNT(id) FROM Person', mapper: (Map<String, Object?> row) => row.values.first as int);
      }
    '''));
  });

  test('query return List<int> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT id FROM Person')
      Future<List<int>> getPeopleIdList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<int>> getPeopleIdList() async {
        return _queryAdapter.queryList('SELECT id FROM Person', mapper: (Map<String, Object?> row) => row.values.first as int);
      }
    '''));
  });

  test('query return List<int> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT id FROM Person')
      Stream<List<int>> getPeopleIdListAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<int>> getPeopleIdListAsStream() {
        return _queryAdapter.queryListStream('SELECT id FROM Person', mapper: (Map<String, Object?> row) => row.values.first as int, queryableName: 'Person', isView: false);
      }
    '''));
  });

  test('query return double type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT weight FROM Person LIMIT 1')
      Future<double?> getFirstPersonWeight();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<double?> getFirstPersonWeight() async {
        return _queryAdapter.query('SELECT weight FROM Person LIMIT 1', mapper: (Map<String, Object?> row) => row.values.first as double);
      }
    '''));
  });

  test('query return List<double> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT weight FROM Person')
      Future<List<double>> getPeopleWeightList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<double>> getPeopleWeightList() async {
        return _queryAdapter.queryList('SELECT weight FROM Person', mapper: (Map<String, Object?> row) => row.values.first as double);
      }
    '''));
  });

  test('query return List<double> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT weight FROM Person')
      Stream<List<double>> getPeopleWeightListAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<double>> getPeopleWeightListAsStream() {
        return _queryAdapter.queryListStream('SELECT weight FROM Person', mapper: (Map<String, Object?> row) => row.values.first as double, queryableName: 'Person', isView: false);
      }
    '''));
  });

  test('query return bool type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT admin FROM Person LIMIT 1')
      Future<bool?> getAdminValue();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<bool?> getAdminValue() async {
        return _queryAdapter.query('SELECT admin FROM Person LIMIT 1', mapper: (Map<String, Object?> row) => (row.values.first as int) != 0);
      }
    '''));
  });

  test('query return List<bool> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT admin FROM Person')
      Future<List<bool>> getAdminValueList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<bool>> getAdminValueList() async {
        return _queryAdapter.queryList('SELECT admin FROM Person', mapper: (Map<String, Object?> row) => (row.values.first as int) != 0);
      }
    '''));
  });

  test('query return List<bool> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT admin FROM Person')
      Stream<List<bool>> getAdminValueListAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<bool>> getAdminValueListAsStream() {
        return _queryAdapter.queryListStream('SELECT admin FROM Person', mapper: (Map<String, Object?> row) => (row.values.first as int) != 0, queryableName: 'Person', isView: false);
      }
    '''));
  });

  test('query return String type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT name FROM Person LIMIT 1')
      Future<String?> getFirstPersonName();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<String?> getFirstPersonName() async {
        return _queryAdapter.query('SELECT name FROM Person LIMIT 1', mapper: (Map<String, Object?> row) => row.values.first as String);
      }
    '''));
  });

  test('query return List<String> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT name FROM Person')
      Future<List<String>> getPeopleNameList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<String>> getPeopleNameList() async {
        return _queryAdapter.queryList('SELECT name FROM Person', mapper: (Map<String, Object?> row) => row.values.first as String);
      }
    '''));
  });

  test('query return List<String> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT name FROM Person')
      Stream<List<String>> getPeopleNameListAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<String>> getPeopleNameListAsStream() {
        return _queryAdapter.queryListStream('SELECT name FROM Person', mapper: (Map<String, Object?> row) => row.values.first as String, queryableName: 'Person', isView: false);
      }
    '''));
  });

  test('query return Uint8List type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT avatar FROM Person LIMIT 1')
      Future<Uint8List?> getFirstPersonAvatar();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Uint8List?> getFirstPersonAvatar() async {
        return _queryAdapter.query('SELECT avatar FROM Person LIMIT 1', mapper: (Map<String, Object?> row) => row.values.first as Uint8List);
      }
    '''));
  });

  test('query return List<Uint8List> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT avatar FROM Person')
      Future<List<Uint8List>> getPeopleAvatarList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Uint8List>> getPeopleAvatarList() async {
        return _queryAdapter.queryList('SELECT avatar FROM Person', mapper: (Map<String, Object?> row) => row.values.first as Uint8List);
      }
    '''));
  });

  test('query return List<Uint8List> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT avatar FROM Person')
      Stream<List<Uint8List>> getPeopleAvatarAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<Uint8List>> getPeopleAvatarAsStream() {
        return _queryAdapter.queryListStream('SELECT avatar FROM Person', mapper: (Map<String, Object?> row) => row.values.first as Uint8List, queryableName: 'Person', isView: false);
      }
    '''));
  });

  test('query return CharacterType type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT someType FROM Person LIMIT 1')
      Future<CharacterType?> getFirstPersonCharacter();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<CharacterType?> getFirstPersonCharacter() async {
        return _queryAdapter.query('SELECT someType FROM Person LIMIT 1', mapper: (Map<String, Object?> row) => CharacterType.values[row.values.first as int]);
      }
    '''));
  });

  test('query return List<CharacterType> type', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT someType FROM Person')
      Future<List<CharacterType>> getPeopleCharacterList();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<CharacterType>> getPeopleCharacterList() async {
        return _queryAdapter.queryList('SELECT someType FROM Person', mapper: (Map<String, Object?> row) => CharacterType.values[row.values.first as int]);
      }
    '''));
  });

  test('query return List<CharacterType> type stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT someType FROM Person')
      Stream<List<CharacterType>> getPeopleCharacterAsStream();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Stream<List<CharacterType>> getPeopleCharacterAsStream() {
        return _queryAdapter.queryListStream('SELECT someType FROM Person', mapper: (Map<String, Object?> row) => CharacterType.values[row.values.first as int], queryableName: 'Person', isView: false);
      }
    '''));
  });

  group('type converters', () {
    test('generates method with external type converter', () async {
      final typeConverter = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final queryMethod = await '''
      @Query('SELECT * FROM Order WHERE id = :id')
      Future<Order?> findById(int id);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order?> findById(int id) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE id = ?1', mapper: (Map<String, Object?> row) => Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)), arguments: [id]);
      }
    '''));
    });

    test('generates method with local method type converter', () async {
      final typeConverter = TypeConverter(
        'ExternalTypeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final queryMethod = await '''
      @TypeConverters([DateTimeConverter])
      @Query('SELECT * FROM Order WHERE dateTime = :dateTime')
      Future<Order?> findByDateTime(DateTime dateTime);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order?> findByDateTime(DateTime dateTime) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE dateTime = ?1', mapper: (Map<String, Object?> row) => Order(row['id'] as int, _externalTypeConverter.decode(row['dateTime'] as int)), arguments: [_dateTimeConverter.encode(dateTime)]);
      }
    '''));
    });

    test('generates method with local method parameter type converter',
        () async {
      final typeConverter = TypeConverter(
        'ExternalTypeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final queryMethod = await '''
      @Query('SELECT * FROM Order WHERE dateTime = :dateTime')
      Future<Order?> findByDateTime(@TypeConverters([DateTimeConverter]) DateTime dateTime);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order?> findByDateTime(DateTime dateTime) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE dateTime = ?1', mapper: (Map<String, Object?> row) => Order(row['id'] as int, _externalTypeConverter.decode(row['dateTime'] as int)), arguments: [_dateTimeConverter.encode(dateTime)]);
      }
    '''));
    });

    test('generates method with type converter receiving list of orders',
        () async {
      final typeConverter = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final queryMethod = await '''
      @Query('SELECT * FROM Order WHERE date IN (:dates)')
      Future<List<Order>> findByDates(List<DateTime> dates);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<List<Order>> findByDates(List<DateTime> dates) async {
        const offset = 1;
        final _sqliteVariablesForDates=Iterable<String>.generate(dates.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Order WHERE date IN (' + _sqliteVariablesForDates + ')', 
          mapper: (Map<String, Object?> row) => Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)),
          arguments: [...dates.map((element) => _dateTimeConverter.encode(element))]);
      }
    '''));
    });

    test('generates method with the type converted return type', () async {
      final typeConverter = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );

      final queryMethod = await '''
      @Query('SELECT timestamp FROM Person')
      Future<List<DateTime>> findTimestampList();
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<List<DateTime>> findTimestampList() async {
        return _queryAdapter.queryList('SELECT timestamp FROM Person', mapper: (Map<String, Object?> row) => _dateTimeConverter.decode(row.values.first as int));
      }
    '''));
    });
  });

  test(
      'Query with multiple IN clauses, reusing and mixing with normal parameters, including converters',
      () async {
    final typeConverter = TypeConverter(
      'DateTimeConverter',
      await dateTimeDartType,
      await intDartType,
      TypeConverterScope.database,
    );
    final queryMethod = await '''
      @Query('SELECT * FROM Order WHERE id IN (:ids) AND id IN (:dateTimeList) OR foo in (:ids) AND bar = :foo OR name = :name')
      Future<List<Order>> findWithIds(List<int> ids, String name, @TypeConverters([DateTimeConverter]) List<DateTime> dateTimeList, DateTime foo);
    '''
        .asOrderQueryMethod({typeConverter});

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
          @override
          Future<List<Order>> findWithIds(
            List<int> ids,
            String name,
            List<DateTime> dateTimeList,
            DateTime foo,
          ) async {
            int offset = 3;
            final _sqliteVariablesForIds =
                Iterable<String>.generate(ids.length, (i) => '?${i + offset}').join(',');
            offset += ids.length;
            final _sqliteVariablesForDateTimeList =
                Iterable<String>.generate(dateTimeList.length, (i) => '?${i + offset}')
                    .join(',');
            return _queryAdapter.queryList(
                'SELECT * FROM Order WHERE id IN (' +
                    _sqliteVariablesForIds +
                    ') AND id IN (' +
                    _sqliteVariablesForDateTimeList +
                    ') OR foo in (' +
                    _sqliteVariablesForIds +
                    ') AND bar = ?2 OR name = ?1',
                mapper: (Map<String, Object?> row) => Order(
                    row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)),
                arguments: [
                  name,
                  _dateTimeConverter.encode(foo),
                  ...ids,
                  ...dateTimeList.map((element) => _dateTimeConverter.encode(element))
                ]);
          }
          '''));
  });

  test('query boolean parameter', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE flag = :flag')
      Future<List<Person>> findWithFlag(bool flag);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
          @override
          Future<List<Person>> findWithFlag(bool flag) async {
            return _queryAdapter.queryList('SELECT * FROM Person WHERE flag = ?1',
                mapper: (Map<String, Object?> row) =>
                    Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                arguments: [flag ? 1 : 0]);
          }
          '''));
  });

  test('query enum parameter', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE characterType = :type')
      Future<List<Person>> findByType(CharacterType type);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
          @override
          Future<List<Person>> findByType(CharacterType type) async {
            return _queryAdapter.queryList(
                'SELECT * FROM Person WHERE characterType = ?1',
                mapper: (Map<String, Object?> row) =>
                    Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                arguments: [type.index]);
          }
          '''));
  });

  test('query item multiple parameters', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id AND name = :name')
      Future<Person?> findById(int id, String name);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
          @override
          Future<Person?> findById(
            int id,
            String name,
          ) async {
            return _queryAdapter.query('SELECT * FROM Person WHERE id = ?1 AND name = ?2',
                mapper: (Map<String, Object?> row) =>
                    Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                arguments: [id, name]);
          }
          '''));
  });

  test('query item multiple mixed and reused parameters', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE foo = :bar AND id = :id AND name = :name AND name = :bar')
      Future<Person?> findById(int id, String name, String bar);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
            @override
            Future<Person?> findById(
              int id,
              String name,
              String bar,
            ) async {
              return _queryAdapter.query(
                  'SELECT * FROM Person WHERE foo = ?3 AND id = ?1 AND name = ?2 AND name = ?3',
                  mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                  arguments: [id, name, bar]);
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
              return _queryAdapter.queryList('SELECT * FROM Person',
                  mapper: (Map<String, Object?> row) =>
                      Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List));
            }
            '''));
  });

  test('query item stream', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :id')
      Stream<Person?> findByIdAsStream(int id);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
            @override
            Stream<Person?> findByIdAsStream(int id) {
              return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?1',
                  mapper: (Map<String, Object?> row) =>
                      Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                  arguments: [id],
                  queryableName: 'Person',
                  isView: false);
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
        return _queryAdapter.queryListStream(
        'SELECT * FROM Person', 
        mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List), 
        queryableName: 'Person', isView: false);
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
        return _queryAdapter.queryListStream(
        'SELECT * FROM Name', 
        mapper: (Map<String, Object?> row) => Name(row['name'] as String), 
        queryableName: 'Name', isView: true);
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
        const offset = 1;
        final _sqliteVariablesForIds=Iterable<String>.generate(ids.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN (' + _sqliteVariablesForIds + ')', 
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List), 
          arguments: [...ids]);
     }
    '''));
  });

  test('writes query with IN clause without space after IN', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id IN(:ids)')
      Future<List<Person>> findWithIds(List<int> ids);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<List<Person>> findWithIds(List<int> ids) async {
        const offset = 1;
        final _sqliteVariablesForIds=Iterable<String>.generate(ids.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN(' + _sqliteVariablesForIds + ')',
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
          arguments: [...ids]);
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
            Future<List<Person>> findWithIds(
              List<int> ids,
              List<int> idx,
            ) async {
              int offset = 1;
              final _sqliteVariablesForIds =
                  Iterable<String>.generate(ids.length, (i) => '?${i + offset}').join(',');
              offset += ids.length;
              final _sqliteVariablesForIdx =
                  Iterable<String>.generate(idx.length, (i) => '?${i + offset}').join(',');
              return _queryAdapter.queryList(
                  'SELECT * FROM Person WHERE id IN (' +
                      _sqliteVariablesForIds +
                      ') AND id IN (' +
                      _sqliteVariablesForIdx +
                      ')',
                  mapper: (Map<String, Object?> row) =>
                      Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                  arguments: [...ids, ...idx]);
            }
            '''));
  });

  test(
      'Query with multiple IN clauses, reusing and mixing with normal parameters',
      () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id IN (:ids) AND id IN (:idx) OR foo in (:ids) AND bar = :foo OR name = :name')
      Future<List<Person>> findWithIds(List<int> idx, String name, List<int> ids, int foo);
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart(r'''
            @override
            Future<List<Person>> findWithIds(
              List<int> idx,
              String name,
              List<int> ids,
              int foo,
            ) async {
              int offset = 3;
              final _sqliteVariablesForIdx =
                  Iterable<String>.generate(idx.length, (i) => '?${i + offset}').join(',');
              offset += idx.length;
              final _sqliteVariablesForIds =
                  Iterable<String>.generate(ids.length, (i) => '?${i + offset}').join(',');
              return _queryAdapter.queryList(
                  'SELECT * FROM Person WHERE id IN (' +
                      _sqliteVariablesForIds +
                      ') AND id IN (' +
                      _sqliteVariablesForIdx +
                      ') OR foo in (' +
                      _sqliteVariablesForIds +
                      ') AND bar = ?2 OR name = ?1',
                  mapper: (Map<String, Object?> row) =>
                      Person(row['id'] as int, row['name'] as String, row['weight'] as double, (row['admin'] as int) != 0, row['avatar'] as Uint8List),
                  arguments: [name, foo, ...idx, ...ids]);
            }
            '''));
  });

  test('query with unsupported type throws', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person?> findById(Person person);
    ''');

    final actual = () => QueryMethodWriter(queryMethod).write();

    expect(actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
  });

  test('query with unsupported void return type throws', () async {
    final queryMethod = () => _createQueryMethod('''
      @Query('DELETE * FROM Person WHERE name = :name')
      void deleteByName(String name);
    ''');

    expect(queryMethod,
        throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
  });

  test('query without TypeConverter for return type throws', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT timestamp FROM Person')
      Future<List<DateTime>> findTimestampList();
    ''');

    final actual = () => QueryMethodWriter(queryMethod).write();

    expect(actual, throwsA(const TypeMatcher<InvalidGenerationSourceError>()));
  });
}

Future<QueryMethod> _createQueryMethod(final String methodSignature) async {
  final dao = await createDao(methodSignature);
  return dao.queryMethods.first;
}

extension on String {
  Future<QueryMethod> asOrderQueryMethod(
    final Set<TypeConverter> typeConverters,
  ) async {
    final dao = await createOrderDao(this, typeConverters);
    return dao.queryMethods.first;
  }
}

Future<Dao> createOrderDao(
  final String methodSignature,
  final Set<TypeConverter> typeConverters,
) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class OrderDao {
        $methodSignature
      }
      
      @entity
      class Order {
        @primaryKey
        final int id;
        
        final DateTime dateTime;
        
        Order(this.id, this.dateTime);
      }
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
              
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
      }
      ''', (resolver) async {
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  final daoClass = library.classes.firstWhere((classElement) =>
      classElement.hasAnnotation(annotations.dao.runtimeType));

  final entities = library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(
            classElement,
            typeConverters,
          ).process())
      .toList();

  return DaoProcessor(
    daoClass,
    'orderDao',
    'TestDatabase',
    entities,
    [],
    typeConverters,
  ).process();
}
