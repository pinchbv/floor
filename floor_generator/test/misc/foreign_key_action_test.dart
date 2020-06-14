import 'package:floor_generator/misc/foreign_key_action.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:test/test.dart';

void main() {
  group('foreign key action strings', () {
    test('NO ACTION', () {
      final actual =
          AnnotationConverter.fromInt(annotations.ForeignKeyAction.noAction)
              .toSQL;
      expect(actual, equals('NO ACTION'));
    });

    test('RESTRICT', () {
      final actual =
          AnnotationConverter.fromInt(annotations.ForeignKeyAction.restrict)
              .toSQL;

      expect(actual, equals('RESTRICT'));
    });

    test('SET NULL', () {
      final actual =
          AnnotationConverter.fromInt(annotations.ForeignKeyAction.setNull)
              .toSQL;

      expect(actual, equals('SET NULL'));
    });

    test('SET DEFAULT', () {
      final actual =
          AnnotationConverter.fromInt(annotations.ForeignKeyAction.setDefault)
              .toSQL;

      expect(actual, equals('SET DEFAULT'));
    });

    test('CASCADE', () {
      final actual =
          AnnotationConverter.fromInt(annotations.ForeignKeyAction.cascade)
              .toSQL;

      expect(actual, equals('CASCADE'));
    });

    test('errors out if action not known', () {
      final conversion = () => AnnotationConverter.fromInt(12345).toSQL;

      expect(conversion, throwsRangeError);
    });
  });
}
