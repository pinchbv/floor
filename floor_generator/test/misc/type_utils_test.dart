import 'dart:typed_data';

import 'package:floor_generator/misc/type_utils.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('assert types', () {
    // TODO #165 rename tests
    test('string is supported type', () async {
      final type = await getDartType("'foo bar'");

      final actual = type.isDefaultSqlType;

      expect(actual, isTrue);
    });

    test('bool is supported type', () async {
      final type = await getDartType(true);

      final actual = type.isDefaultSqlType;

      expect(actual, isTrue);
    });

    test('int is supported type', () async {
      final type = await getDartType(1);

      final actual = type.isDefaultSqlType;

      expect(actual, isTrue);
    });

    test('double is supported type', () async {
      final type = await getDartType(1.1);

      final actual = type.isDefaultSqlType;

      expect(actual, isTrue);
    });

    test('Uint8List is supported type', () async {
      final type = await getDartType(Uint8List(10));

      final actual = type.isDefaultSqlType;

      expect(actual, isTrue);
    });

    test('is stream', () async {
      final type = await getDartTypeFromString('Stream<String>.empty()');

      final actual = type.isStream;

      expect(actual, isTrue);
    });

    test('is not stream', () async {
      final type = await getDartType(1);

      final actual = type.isStream;

      expect(actual, isFalse);
    });
  });

  group('flatten', () {
    test('flatten list', () async {
      final type = await getDartTypeFromString('<int>[]');

      final actual = type.flatten();

      expect(actual.isDartCoreInt, isTrue);
    });

    test('flatten stream', () async {
      final type = await getDartTypeFromString('Stream<int>.empty()');

      final actual = type.flatten();

      expect(actual.isDartCoreInt, isTrue);
    });
  });
}
