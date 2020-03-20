import 'package:floor_generator/misc/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('decapitalize word (first letter to lowercase)', () {
    final actual = 'FOO'.decapitalize();

    expect(actual, 'fOO');
  });

  group('flatten()', () {
    test('flattens multiline string', () {
      final actual = '''
      first
      second
      third
      '''
          .flatten();

      expect(actual, equals('first second third'));
    });

    test('does nothing to singleline string', () {
      const string = 'first second third';

      final actual = string.flatten();

      expect(actual, equals(string));
    });

    test('does nothing to concatenated string', () async {
      const string = 'first '
          'second '
          'third';

      final actual = string.flatten();

      expect(actual, equals('first second third'));
    });

    test('removes leading and trailing whitespace', () {
      final actual = ' first '.flatten();

      expect(actual, equals('first'));
    });
  });
}
