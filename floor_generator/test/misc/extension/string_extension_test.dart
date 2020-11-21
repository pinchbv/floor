import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:test/test.dart';

void main() {
  group('decapitalize', () {
    test('returns empty string for empty string', () {
      final actual = ''.decapitalize();

      expect(actual, equals(''));
    });

    test('decapitalizes first character for single character string', () {
      final actual = 'A'.decapitalize();

      expect(actual, equals('a'));
    });

    test('decapitalize word (first letter to lowercase)', () {
      final actual = 'FOO'.decapitalize();

      expect(actual, equals('fOO'));
    });
  });
}
