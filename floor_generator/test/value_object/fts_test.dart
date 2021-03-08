import 'package:floor_generator/value_object/fts.dart';
import 'package:test/test.dart';

void main() {
  group('Fts tests', () {
    test('Fts3 Definition', () {
      final Fts fts = Fts3(
        'simple',
        [],
      );

      final usingOptionActual = fts.usingOption;

      const usingOptionExpected = 'USING fts3';

      expect(usingOptionActual, equals(usingOptionExpected));

      final tableCreateActual = fts.tableCreateOption();

      const tableCreateExpected = 'tokenize=simple ';

      expect(tableCreateActual, equals(tableCreateExpected));
    });

    test('Fts4 Definition', () {
      final Fts fts = Fts4(
        'icu',
        ['th_TH'],
      );

      final usingOptionActual = fts.usingOption;

      const usingOptionExpected = 'USING fts4';

      expect(usingOptionActual, equals(usingOptionExpected));

      final tableCreateActual = fts.tableCreateOption();

      const tableCreateExpected = 'tokenize=icu th_TH';

      expect(tableCreateActual, equals(tableCreateExpected));
    });
  });

  test('Fts toString', () {
    final Fts fts = Fts4(
      'icu',
      ['th_TH'],
    );

    final actual = fts.toString();

    const expected = 'Fts{type: USING fts4, tokenizer: tokenize=icu th_TH}';

    expect(actual, equals(expected));
  });
}
