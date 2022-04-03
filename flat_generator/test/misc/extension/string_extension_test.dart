import 'package:flat_generator/misc/extension/string_extension.dart';
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

  group('capitalize', () {
    test('returns empty string for empty string', () {
      expect(''.capitalize(), equals(''));
    });

    test('capitalizes first character for single character string', () {
      expect('a'.capitalize(), equals('A'));
    });

    test('does nothing for single capitalized character string', () {
      expect('A'.capitalize(), equals('A'));
    });

    test('capitalize word (first letter to lowercase)', () {
      expect('fOO'.capitalize(), equals('FOO'));
    });
  });

  group('toLiteral', () {
    test('null', () {
      expect(null.toLiteral(), equals('null'));
    });

    test('empty string', () {
      expect(''.toLiteral(), equals("''"));
    });

    test('Single-character-string', () {
      expect('A'.toLiteral(), equals("'A'"));
    });

    test('Escaping \'', () {
      expect("a'd'b".toLiteral(), equals("'a\\'d\\'b'"));
    });

    test('Escaping \n', () {
      expect('A\ns\t'.toLiteral(), equals("'A\\ns\\t'"));
    });

    test('long-string', () {
      final actual = 'The quick brown fox jumps over the lazy dog'.toLiteral();
      expect(actual, equals("'The quick brown fox jumps over the lazy dog'"));
    });
  });
}
