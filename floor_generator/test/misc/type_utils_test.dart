import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('Type assertions', () {
    group('default SQL type assertions', () {
      test('string is default SQL type', () async {
        final type = await getDartType("'foo bar'");

        final actual = type.isDefaultSqlType;

        expect(actual, isTrue);
      });

      test('bool is default SQL type', () async {
        final type = await getDartType(true);

        final actual = type.isDefaultSqlType;

        expect(actual, isTrue);
      });

      test('int is default SQL type', () async {
        final type = await getDartType(1);

        final actual = type.isDefaultSqlType;

        expect(actual, isTrue);
      });

      test('double is default SQL type', () async {
        final type = await getDartType(1.1);

        final actual = type.isDefaultSqlType;

        expect(actual, isTrue);
      });

      test('Uint8List is default SQL type', () async {
        final type = await getDartType('Uint8List(10)');

        final actual = type.isDefaultSqlType;

        expect(actual, isTrue);
      });
    });

    group('stream assertion', () {
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
  });

  group('flatten', () {
    test('flatten list', () async {
      final type = await getDartTypeFromString('<int>[]');

      // Type from String is returned as function, so use returnType
      final actual = type.flatten();

      expect(actual.isDartCoreInt, isTrue);
    });

    test('flatten stream', () async {
      final type = await getDartTypeFromString('Stream<int>.empty()');

      // Type from String is returned as function, so use returnType
      final actual = type.flatten();

      expect(actual.isDartCoreInt, isTrue);
    });
  });
}
