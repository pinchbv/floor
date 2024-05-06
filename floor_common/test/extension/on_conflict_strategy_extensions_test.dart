import 'package:floor_common/floor_common.dart';
import 'package:floor_common/src/extension/on_conflict_strategy_extensions.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:test/test.dart';

void main() {
  group('asSqfliteConflictAlgorithm', () {
    test('replace', () {
      const onConflictStrategy = OnConflictStrategy.replace;

      final actual = onConflictStrategy.asSqfliteConflictAlgorithm();

      expect(actual, equals(ConflictAlgorithm.replace));
    });

    test('rollback', () {
      const onConflictStrategy = OnConflictStrategy.rollback;

      final actual = onConflictStrategy.asSqfliteConflictAlgorithm();

      expect(actual, equals(ConflictAlgorithm.rollback));
    });

    test('fail', () {
      const onConflictStrategy = OnConflictStrategy.fail;

      final actual = onConflictStrategy.asSqfliteConflictAlgorithm();

      expect(actual, equals(ConflictAlgorithm.fail));
    });

    test('ignore', () {
      const onConflictStrategy = OnConflictStrategy.ignore;

      final actual = onConflictStrategy.asSqfliteConflictAlgorithm();

      expect(actual, equals(ConflictAlgorithm.ignore));
    });

    test('abort', () {
      const onConflictStrategy = OnConflictStrategy.abort;

      final actual = onConflictStrategy.asSqfliteConflictAlgorithm();

      expect(actual, equals(ConflictAlgorithm.abort));
    });
  });
}
