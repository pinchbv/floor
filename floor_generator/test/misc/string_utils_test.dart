import 'package:floor_generator/misc/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('decapitalize word', () {
    const string = 'Foo';

    final actual = decapitalize(string);

    expect(actual, 'foo');
  });
}
