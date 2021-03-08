// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/type_converter_field_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('Writes type converter field', () {
    final actual = TypeConverterFieldWriter('FooTypeConverter').write();

    expect(actual, equalsDart('''
      final _fooTypeConverter = FooTypeConverter();
    '''));
  });
}
