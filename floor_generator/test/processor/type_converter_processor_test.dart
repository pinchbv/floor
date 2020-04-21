import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/type_converter_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

// TODO #165
void main() {
  test('foo', () async {
    final classElement = await '''
      class DateTimeToIntConverter extends TypeConverter<DateTime, int> {
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
      TypeConverterScope.dao,
    ).process();

    final expected = TypeConverter(
      'DateTimeToIntConverter',
      await getDartTypeFromString('DateTime.now()'),
      await getDartTypeFromString('1'),
      TypeConverterScope.dao,
    );
    expect(actual, equals(expected));
  });
}

extension on String {
  Future<DartType> asDartType() async {
    return getDartTypeFromString(this);
  }

  Future<ClassElement> asClassElement() async {
    final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $this
      ''', (resolver) async {
      return LibraryReader(await resolver.findLibraryByName('test'));
    });

    return library.classes.first;
  }
}
