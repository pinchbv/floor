import 'package:floor_generator/misc/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('decapitalize word (first letter to lowercase)', () {
    final actual = 'FOO'.decapitalize();

    expect(actual, 'fOO');
  });
}
