import 'package:floor_generator/misc/extension/foreign_key_action.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:test/test.dart';

void main() {
  group('foreign key action strings', () {
    test('NO ACTION', () {
      final actual = annotations.ForeignKeyAction.noAction.toSQL;
      expect(actual, equals('NO ACTION'));
    });

    test('RESTRICT', () {
      final actual = annotations.ForeignKeyAction.restrict.toSQL;
      expect(actual, equals('RESTRICT'));
    });

    test('SET NULL', () {
      final actual = annotations.ForeignKeyAction.setNull.toSQL;
      expect(actual, equals('SET NULL'));
    });

    test('SET DEFAULT', () {
      final actual = annotations.ForeignKeyAction.setDefault.toSQL;
      expect(actual, equals('SET DEFAULT'));
    });

    test('CASCADE', () {
      final actual = annotations.ForeignKeyAction.cascade.toSQL;
      expect(actual, equals('CASCADE'));
    });

    test('null annotation returns null', () {
      final actual = null.toSQL;
      expect(actual, isNull);
    });
  });
}
