import 'package:floor_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

void main() {
  test('database index is smallest', () {
    final actual = TypeConverterScope.database.index < TypeConverterScope.dao.index;

    expect(actual, isTrue);
  });
}
