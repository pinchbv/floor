// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor_generator/processor/type_converter_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('TypeConverterProcessor', () {
    test('Creates type converter with given scope', () async {
      const typeConverterScope = TypeConverterScope.dao;
      final classElement = await '''
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
    '''
          .asClassElement();

      final actual = TypeConverterProcessor(
        classElement,
        typeConverterScope,
      ).process();

      final expected = TypeConverter(
        'DateTimeConverter',
        await 'DateTime.now()'.asDartType(),
        await '1'.asDartType(),
        typeConverterScope,
      );
      expect(actual, equals(expected));
    });

    test("throws error when converter's database type is not supported",
        () async {
      final classElement = await '''
      class DateTimeConverter extends TypeConverter<DateTime, DateTime> {
        @override
        DateTime encode(DateTime value) {
          return value;
        }
      
        @override
        DateTime decode(DateTime databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
      }
    '''
          .asClassElement();

      final actual = () => TypeConverterProcessor(
            classElement,
            TypeConverterScope.dao,
          ).process();

      expect(actual, throwsInvalidGenerationSourceError());
    });
  });
}
