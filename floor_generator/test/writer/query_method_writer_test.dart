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
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ?', arguments: <dynamic>[id], mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
      Future<Order> findById(int id);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order> findById(int id) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE id = ?', arguments: <dynamic>[id], mapper: (Map<String, dynamic> row) => Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)));
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
      Future<Order> findByDateTime(DateTime dateTime);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order> findByDateTime(DateTime dateTime) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE dateTime = ?', arguments: <dynamic>[_dateTimeConverter.encode(dateTime)], mapper: (Map<String, dynamic> row) => Order(row['id'] as int, _externalTypeConverter.decode(row['dateTime'] as int)));
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
      Future<Order> findByDateTime(@TypeConverters([DateTimeConverter]) DateTime dateTime);
    '''
          .asOrderQueryMethod({typeConverter});

      final actual = QueryMethodWriter(queryMethod).write();

      expect(actual, equalsDart(r'''
      @override
      Future<Order> findByDateTime(DateTime dateTime) async {
        return _queryAdapter.query('SELECT * FROM Order WHERE dateTime = ?', arguments: <dynamic>[_dateTimeConverter.encode(dateTime)], mapper: (Map<String, dynamic> row) => Order(row['id'] as int, _externalTypeConverter.decode(row['dateTime'] as int)));
      }
    '''));
    });

    test(
        'generates method with type converter receiving list of orders',
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
        final valueList0 = dates.map((value) => "'${_dateTimeConverter.encode(value)}'").join(', ');
        return _queryAdapter.queryList('SELECT * FROM Order WHERE date IN ($valueList0)', mapper: (Map<String, dynamic> row) => Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int)));
      }
    '''));
    });
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
        return _queryAdapter.queryList('SELECT * FROM Person WHERE flag = ?', arguments: <dynamic>[flag == null ? null : (flag ? 1 : 0)], mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.query('SELECT * FROM Person WHERE id = ? AND name = ?', arguments: <dynamic>[id, name], mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.queryList('SELECT * FROM Person', mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?', arguments: <dynamic>[id], queryableName: 'Person', isView: false, mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.queryListStream('SELECT * FROM Person', queryableName: 'Person', isView: false, mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        return _queryAdapter.queryListStream('SELECT * FROM Name', queryableName: 'Name', isView: true, mapper: (Map<String, dynamic> row) => Name(row['name'] as String));
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
        final valueList0 = ids.map((value) => "'$value'").join(', ');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN ($valueList0)', mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
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
        final valueList0 = ids.map((value) => "'$value'").join(', ');
        final valueList1 = idx.map((value) => "'$value'").join(', ');
        return _queryAdapter.queryList('SELECT * FROM Person WHERE id IN ($valueList0) AND id IN ($valueList1)', mapper: (Map<String, dynamic> row) => Person(row['id'] as int, row['name'] as String));
      }
    '''));
  });

  test('query with unsupported type throws', () async {
    final queryMethod = await _createQueryMethod('''
      @Query('SELECT * FROM Person WHERE id = :person')
      Future<Person> findById(Person person);
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
    return LibraryReader(await resolver.findLibraryByName('test'));
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
