import 'package:flat_generator/value_object/index.dart';
import 'package:test/test.dart';

void main() {
  test('create index', () {
    const name = 'foo';
    const tableName = 'bar';
    const unique = false;
    const columnNames = ['baz', 'off'];

    final actual = Index(name, tableName, unique, columnNames).createQuery();

    final expected =
        'CREATE INDEX `$name` ON `$tableName` (${columnNames.map((name) => '`$name`').join(', ')})';
    expect(actual, equals(expected));
  });

  test('create unique index', () {
    const name = 'foo';
    const tableName = 'bar';
    const unique = true;
    const columnNames = ['baz', 'off'];

    final actual = Index(name, tableName, unique, columnNames).createQuery();

    final expected =
        'CREATE UNIQUE INDEX `$name` ON `$tableName` (${columnNames.map((name) => '`$name`').join(', ')})';
    expect(actual, equals(expected));
  });
}
