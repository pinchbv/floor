import 'package:floor_generator/misc/type_utils.dart' as type_utils;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('assert type', () {
    test('is string', () async {
      final type = await getDartType("'123'");

      final actual = type_utils.isString(type);

      expect(actual, isTrue);
    });

    test('is not string', () async {
      final type = await getDartType(1);

      final actual = type_utils.isString(type);

      expect(actual, isFalse);
    });

    test('is bool', () async {
      final type = await getDartType(true);

      final actual = type_utils.isBool(type);

      expect(actual, isTrue);
    });

    test('is not bool', () async {
      final type = await getDartType(1);

      final actual = type_utils.isBool(type);

      expect(actual, isFalse);
    });

    test('is int', () async {
      final type = await getDartType(1);

      final actual = type_utils.isInt(type);

      expect(actual, isTrue);
    });

    test('is not int', () async {
      final type = await getDartType(1.1);

      final actual = type_utils.isInt(type);

      expect(actual, isFalse);
    });

    test('is double', () async {
      final type = await getDartType(1.1);

      final actual = type_utils.isDouble(type);

      expect(actual, isTrue);
    });

    test('is not double', () async {
      final type = await getDartType(1);

      final actual = type_utils.isDouble(type);

      expect(actual, isFalse);
    });

    test('is list', () async {
      final type = await getDartType([1, 2, 3]);

      final actual = type_utils.isList(type);

      expect(actual, isTrue);
    });

    test('is not list', () async {
      final type = await getDartType(1);

      final actual = type_utils.isList(type);

      expect(actual, isFalse);
    });

    test('is supported type', () async {
      final type = await getDartType(1);

      final actual = type_utils.isSupportedType(type);

      expect(actual, isTrue);
    });

    test('is stream', () async {
      final type = await getDartTypeFromString('Stream<String>.empty()');

      final actual = type_utils.isStream(type);

      expect(actual, isTrue);
    });

    test('it not stream', () async {
      final type = await getDartType(1);

      final actual = type_utils.isStream(type);

      expect(actual, isFalse);
    });
  });

  group('flatten', () {
    test('flatten list', () async {
      final type = await getDartTypeFromString('<int>[]');

      final actual = type_utils.flattenList(type);

      expect(actual.isDartCoreInt, isTrue);
    });

    test('flatten stream', () async {
      final type = await getDartTypeFromString('Stream<int>.empty()');

      final actual = type_utils.flattenStream(type);

      expect(actual.isDartCoreInt, isTrue);
    });
  });
}
