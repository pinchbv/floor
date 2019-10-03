import 'package:floor_generator/misc/foreign_key_action.dart';
import 'package:test/test.dart';

void main() {
  group('foreign key action strings', () {
    test('NO ACTION', () {
      final actual = ForeignKeyAction.getString(ForeignKeyAction.NO_ACTION);

      expect(actual, equals('NO ACTION'));
    });

    test('RESTRICT', () {
      final actual = ForeignKeyAction.getString(ForeignKeyAction.RESTRICT);

      expect(actual, equals('RESTRICT'));
    });

    test('SET NULL', () {
      final actual = ForeignKeyAction.getString(ForeignKeyAction.SET_NULL);

      expect(actual, equals('SET NULL'));
    });

    test('SET DEFAULT', () {
      final actual = ForeignKeyAction.getString(ForeignKeyAction.SET_DEFAULT);

      expect(actual, equals('SET DEFAULT'));
    });

    test('CASCADE', () {
      final actual = ForeignKeyAction.getString(ForeignKeyAction.CASCADE);

      expect(actual, equals('CASCADE'));
    });

    test('falls back to NO ACTION is action not knonw', () {
      final actual = ForeignKeyAction.getString(12345);

      expect(actual, equals('NO ACTION'));
    });
  });
}
