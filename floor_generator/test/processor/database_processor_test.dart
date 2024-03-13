import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/database_processor.dart';
import 'package:floor_generator/processor/error/database_processor_error.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../dart_type.dart';
import '../test_utils.dart';

void main() {
  group('type converters', () {
    test('collects database type converters', () async {
      final classElement = await _createDatabaseClassElement('''
      @TypeConverters([DateTimeConverter])
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {}
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
            
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
      }
    ''');

      final actual =
          DatabaseProcessor(classElement).process().databaseTypeConverters;

      final expected = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      expect(actual, equals([expected]));
    });

    test('collects all type converters', () async {
      final classElement = await _createDatabaseClassElement('''
      @Database(version: 1, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {
        PersonDao get personDao;
      }
      
      @TypeConverters([DateTimeConverter])
      @dao
      abstract class PersonDao {}
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
            
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
      }
    ''');

      final actual =
          DatabaseProcessor(classElement).process().allTypeConverters;

      final expected = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.dao,
      );
      expect(actual, equals({expected}));
    });
  });

  test('error when database version < 1', () async {
    final classElement = await _createDatabaseClassElement('''
      @Database(version: 0, entities: [Person])
      abstract class TestDatabase extends FloorDatabase {}
    ''');

    final actual = () => DatabaseProcessor(classElement).process();

    final error = DatabaseProcessorError(classElement).versionIsBelowOne;
    expect(actual, throwsInvalidGenerationSourceError(error));
  });

  test('error when database version not supplied', () async {
    final classElement = await _createDatabaseClassElement('''
      @Database(entities: [Person])
      abstract class TestDatabase extends FloorDatabase {}
    ''');

    final actual = () => DatabaseProcessor(classElement).process();

    final error = DatabaseProcessorError(classElement).versionIsMissing;
    expect(actual, throwsInvalidGenerationSourceError(error));
  });

  test(
    'error when database annotation contains no entities (empty list)',
    () async {
      final classElement = await _createDatabaseClassElement('''
      @Database(version: 1, entities: [])
      abstract class TestDatabase extends FloorDatabase {}
    ''');

      final actual = () => DatabaseProcessor(classElement).process();

      final error = DatabaseProcessorError(classElement).noEntitiesDefined;
      expect(actual, throwsInvalidGenerationSourceError(error));
    },
  );

  test('error when database annotation contains no entities (null)', () async {
    final classElement = await _createDatabaseClassElement('''
      @Database(version: 1)
      abstract class TestDatabase extends FloorDatabase {}
    ''');

    final actual = () => DatabaseProcessor(classElement).process();

    final error = DatabaseProcessorError(classElement).noEntitiesDefined;
    expect(actual, throwsInvalidGenerationSourceError(error));
  });
}

Future<ClassElement> _createDatabaseClassElement(
  final String database,
) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $database
      
      @entity
      class Person {
        @PrimaryKey()
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
      ''', (resolver) async {
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  return library.classes.first;
}
