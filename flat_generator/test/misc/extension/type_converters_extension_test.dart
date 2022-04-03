import 'package:flat_generator/misc/extension/type_converters_extension.dart';
import 'package:flat_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

import '../../dart_type.dart';
import '../../test_utils.dart';

void main() {
  group('closestOrNull', () {
    test('returns closest type converter', () async {
      final databaseTypeConverter = TypeConverter(
        'database type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final daoMethodTypeConverter = TypeConverter(
        'DAO method type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.daoMethod,
      );
      final typeConverters = [databaseTypeConverter, daoMethodTypeConverter];

      final actual = typeConverters.closestOrNull;

      expect(actual, equals(daoMethodTypeConverter));
    });

    test('returns null when no type converter found', () {
      final actual = <TypeConverter>[].closestOrNull;

      expect(actual, isNull);
    });
  });

  group('getClosestOrNull', () {
    test('returns closest type converter for DartType', () async {
      final databaseTypeConverter = TypeConverter(
        'database type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final daoMethodTypeConverter = TypeConverter(
        'DAO method type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.daoMethod,
      );
      final typeConverters = [databaseTypeConverter, daoMethodTypeConverter];

      final actual = typeConverters.getClosestOrNull(await dateTimeDartType);

      expect(actual, equals(daoMethodTypeConverter));
    });

    test('returns null when not type converter for DartType found', () async {
      final typeConverter = TypeConverter(
        'database type converter',
        await stringDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final typeConverters = [typeConverter];

      final actual = typeConverters.getClosestOrNull(await dateTimeDartType);

      expect(actual, isNull);
    });
  });

  group('getClosest', () {
    test('returns closest type converter for DartType', () async {
      final databaseTypeConverter = TypeConverter(
        'database type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final daoMethodTypeConverter = TypeConverter(
        'DAO method type converter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.daoMethod,
      );
      final typeConverters = [databaseTypeConverter, daoMethodTypeConverter];

      final actual = typeConverters.getClosest(await dateTimeDartType);

      expect(actual, equals(daoMethodTypeConverter));
    });

    test('throws error when no type converter found for DartType', () async {
      final typeConverter = TypeConverter(
        'database type converter',
        await stringDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final typeConverters = [typeConverter];

      final actual =
          () async => typeConverters.getClosest(await dateTimeDartType);

      expect(actual, throwsInvalidGenerationSourceError());
    });
  });
}
