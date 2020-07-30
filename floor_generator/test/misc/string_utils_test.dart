import 'package:floor_generator/misc/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('decapitalize word (first letter to lowercase)', () {
    final actual = 'FOO'.decapitalize();

    expect(actual, 'fOO');
  });

  test('capitalize word (first letter to uppercase)', () {
    expect('foo'.capitalize(), 'Foo');
    expect('FOO'.capitalize(), 'FOO');
    expect('00f'.capitalize(), '00f');
  });

  test('convert string to string literal', () {
    expect('foo'.toLiteral(), "'foo'");
    expect('"foo"'.toLiteral(), "'\\\"foo\\\"'");
    expect('\'foo\''.toLiteral(), "'\\'foo\\''");
    expect('fo\no'.toLiteral(), "'fo\\no'");
    expect(null.toLiteral(), 'null');
  });
}
