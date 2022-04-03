import 'package:flat_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

import '../dart_type.dart';

void main() {
  test('database index is smallest', () {
    final actual =
        TypeConverterScope.database.index < TypeConverterScope.dao.index;

    expect(actual, isTrue);
  });

  test('equals returns true for equal TypeConverter objects', () async {
    final dateTime = await dateTimeDartType;
    final int = await intDartType;
    final firstTypeConverter = TypeConverter(
      'DateTimeConverter',
      dateTime,
      int,
      TypeConverterScope.database,
    );
    final secondTypeConverter = TypeConverter(
      'DateTimeConverter',
      dateTime,
      int,
      TypeConverterScope.database,
    );

    final actual = firstTypeConverter == secondTypeConverter;

    expect(actual, isTrue);
  });
}
