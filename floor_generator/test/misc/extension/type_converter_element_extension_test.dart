import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

import '../../test_utils.dart';

void main() {
  group('getTypeConverters', () {
    test('gets type converters from annotation with supplied scope', () async {
      const typeConverterScope = TypeConverterScope.database;
      final element = await '''
        @TypeConverters([DateTimeConverter])
        abstract class Foo {}
        
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

      final actual = element.getTypeConverters(typeConverterScope);

      final expected = TypeConverter(
        'DateTimeConverter',
        await 'DateTime.now()'.asDartType(),
        await '1'.asDartType(),
        typeConverterScope,
      );
      expect(actual, equals({expected}));
    });

    test('throws error when null in annotation', () async {
      const typeConverterScope = TypeConverterScope.database;
      final element = await '''
        @TypeConverters(null)
        abstract class Foo {}
      '''
          .asClassElement();

      final actual = () => element.getTypeConverters(typeConverterScope);

      expect(actual, throwsUnresolvedAnnotationException());
    });

    test('throws error when empty list in annotation', () async {
      const typeConverterScope = TypeConverterScope.database;
      final element = await '''
        @TypeConverters([])
        abstract class Foo {}
      '''
          .asClassElement();

      final actual = () => element.getTypeConverters(typeConverterScope);

      expect(actual, throwsProcessorError());
    });

    test('throws error when element in annotation is not TypeConverter',
        () async {
      const typeConverterScope = TypeConverterScope.database;
      final element = await '''
        @TypeConverters([String])
        abstract class Foo {}
      '''
          .asClassElement();

      final actual = () => element.getTypeConverters(typeConverterScope);

      expect(actual, throwsProcessorError());
    });
  });
}
