import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:flat_annotation/flat_annotation.dart' as annotations;
import 'package:flat_generator/misc/type_utils.dart';
import 'package:flat_generator/processor/dao_processor.dart';
import 'package:flat_generator/processor/entity_processor.dart';
import 'package:flat_generator/value_object/dao.dart';
import 'package:flat_generator/value_object/query_method.dart';
import 'package:flat_generator/value_object/type_converter.dart';
import 'package:flat_generator/writer/query_method_writer.dart';
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
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ?1', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), arguments: [id]);
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
      Future<List<Order>> findWithIds(List<int> ids, String name, List<DateTime> dateTimeList, DateTime foo) async {
        int offset = 3;
        final _sqliteVariablesForIds=Iterable<String>.generate(ids.length, (i)=>'?${i+offset}').join(',');
        offset += ids.length;
        final _sqliteVariablesForDateTimeList=Iterable<String>.generate(dateTimeList.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Order WHERE id IN (' + _sqliteVariablesForIds + ') AND id IN (' + _sqliteVariablesForDateTimeList + ') OR foo in (' + _sqliteVariablesForIds + ') AND bar = ?2 OR name = ?1', 
          mapper: (Map<String, Object?> row) => Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)),
          arguments: [name, _dateTimeConverter.encode(foo), ...ids, ...dateTimeList.map((element) => _dateTimeConverter.encode(element))]);
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
        return _queryAdapter.queryList('SELECT * FROM Person WHERE flag = ?1', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), arguments: [flag ? 1 : 0]);
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
      Future<Person?> findById(int id, String name) async {
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ?1 AND name = ?2', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), arguments: [id, name]);
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
      Future<Person?> findById(int id, String name, String bar) async {
        return _queryAdapter.query('SELECT * FROM Person WHERE foo = ?3 AND id = ?1 AND name = ?2 AND name = ?3', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), arguments: [id, name, bar]);
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
        return _queryAdapter.queryList('SELECT * FROM Person', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?1', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), arguments: [id], queryableName: 'Person', isView: false);
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
        return _queryAdapter.queryListStream('SELECT * FROM Person', mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), queryableName: 'Person', isView: false);
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
        return _queryAdapter.queryListStream('SELECT * FROM Name', mapper: (Map<String, Object?> row) => Name(row['name'] as String), queryableName: 'Name', isView: true);
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
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), 
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
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String),
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
      Future<List<Person>> findWithIds(List<int> ids, List<int> idx) async {
        int offset = 1;
        final _sqliteVariablesForIds=Iterable<String>.generate(ids.length, (i)=>'?${i+offset}').join(',');
        offset += ids.length;
        final _sqliteVariablesForIdx=Iterable<String>.generate(idx.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN (' + _sqliteVariablesForIds + ') AND id IN (' + _sqliteVariablesForIdx + ')',
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String),
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
      Future<List<Person>> findWithIds(List<int> idx, String name, List<int> ids, int foo) async {
        int offset = 3;
        final _sqliteVariablesForIdx=Iterable<String>.generate(idx.length, (i)=>'?${i+offset}').join(',');
        offset += idx.length;
        final _sqliteVariablesForIds=Iterable<String>.generate(ids.length, (i)=>'?${i+offset}').join(',');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN (' + _sqliteVariablesForIds + ') AND id IN (' + _sqliteVariablesForIdx + ') OR foo in (' + _sqliteVariablesForIds + ') AND bar = ?2 OR name = ?1', 
          mapper: (Map<String, Object?> row) => Person(row['id'] as int, row['name'] as String), 
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
      
      import 'package:flat_annotation/flat_annotation.dart';
      
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
    return LibraryReader((await resolver.findLibraryByName('test'))!);
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
