import 'package:floor/src/util/query_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Primary key query', () {
    test('Get group primary key query with single primary key', () {
      final primaryKey = ['foo'];

      final actual = QueryFormatter.getGroupPrimaryKeyQuery(primaryKey);

      const expected = 'foo = ?';
      expect(actual, equals(expected));
    });

    test('Get group primary key query with composit primary key', () {
      final primaryKey = ['foo', 'bar'];

      final actual = QueryFormatter.getGroupPrimaryKeyQuery(primaryKey);

      const expected = 'foo = ? AND bar = ?';
      expect(actual, equals(expected));
    });
  });

  group('Primary key arguments', () {
    test('Get group primary key argument with single primary key', () {
      final values = {'foo': 1};
      final primaryKey = ['foo'];

      final actual = QueryFormatter.getGroupPrimaryKeyArgs(values, primaryKey);

      final expected = [1];
      expect(actual, equals(expected));
    });

    test('Get group primary key arguments with composit primary key', () {
      final values = {'foo': 1, 'bar': 2};
      final primaryKey = ['foo', 'bar'];

      final actual = QueryFormatter.getGroupPrimaryKeyArgs(values, primaryKey);

      final expected = [1, 2];
      expect(actual, equals(expected));
    });
  });
}
