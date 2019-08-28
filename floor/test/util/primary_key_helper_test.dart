import 'package:floor/src/util/primary_key_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Primary key WHERE clause', () {
    test('Get primary key WHERE clause with single primary key', () {
      final primaryKey = ['foo'];

      final actual = PrimaryKeyHelper.getWhereClause(primaryKey);

      const expected = 'foo = ?';
      expect(actual, equals(expected));
    });

    test('Get group primary key WHERE clause with composit primary key', () {
      final primaryKey = ['foo', 'bar'];

      final actual = PrimaryKeyHelper.getWhereClause(primaryKey);

      const expected = 'foo = ? AND bar = ?';
      expect(actual, equals(expected));
    });
  });

  group('Primary key values', () {
    test('Get group primary key value from single primary key', () {
      final primaryKey = ['foo'];
      final values = {'foo': 1};

      final actual = PrimaryKeyHelper.getPrimaryKeyValues(primaryKey, values);

      final expected = [1];
      expect(actual, equals(expected));
    });

    test('Get group primary key values from composit primary key', () {
      final primaryKey = ['foo', 'bar'];
      final values = {'foo': 1, 'bar': 2};

      final actual = PrimaryKeyHelper.getPrimaryKeyValues(primaryKey, values);

      final expected = [1, 2];
      expect(actual, equals(expected));
    });
  });
}
