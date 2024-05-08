import 'package:test/test.dart';

import 'type_converter.dart';

void main() {
  final underTest = DateTimeConverter();

  test('encode DateTime to int', () {
    const milliseconds = 123456;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    final actual = underTest.encode(dateTime);

    expect(actual, equals(milliseconds));
  });

  test('decode int to DateTime', () {
    const milliseconds = 123456;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    final actual = underTest.decode(milliseconds);

    expect(actual, equals(dateTime));
  });
}
