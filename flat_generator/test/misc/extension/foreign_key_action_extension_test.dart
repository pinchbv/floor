import 'package:flat_annotation/flat_annotation.dart' as annotations;
import 'package:flat_generator/misc/extension/foreign_key_action_extension.dart';
import 'package:test/test.dart';

void main() {
  group('foreign key action strings', () {
    test('NO ACTION', () {
      final actual = annotations.ForeignKeyAction.noAction.toSql();
      expect(actual, equals('NO ACTION'));
    });

    test('RESTRICT', () {
      final actual = annotations.ForeignKeyAction.restrict.toSql();
      expect(actual, equals('RESTRICT'));
    });

    test('SET NULL', () {
      final actual = annotations.ForeignKeyAction.setNull.toSql();
      expect(actual, equals('SET NULL'));
    });

    test('SET DEFAULT', () {
      final actual = annotations.ForeignKeyAction.setDefault.toSql();
      expect(actual, equals('SET DEFAULT'));
    });

    test('CASCADE', () {
      final actual = annotations.ForeignKeyAction.cascade.toSql();
      expect(actual, equals('CASCADE'));
    });
  });
}
