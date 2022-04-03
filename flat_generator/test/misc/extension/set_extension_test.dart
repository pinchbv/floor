import 'package:flat_generator/misc/extension/set_extension.dart';
import 'package:test/test.dart';

void main() {
  group('+', () {
    test('combines elements of two sets', () {
      final firstSet = {'abc', 'def'};
      final secondSet = {'abc', 'ghi'};

      final actual = firstSet + secondSet;

      expect(actual, equals({'abc', 'def', 'ghi'}));
    });
  });
}
