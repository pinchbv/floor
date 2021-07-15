import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:test/test.dart';

void main() {
  group('foreign key tests', () {
    test('getDefinition for single child and parent column', () {
      final foreignKey = ForeignKey(
        'Person',
        ['id'],
        ['owner_id'],
        annotations.ForeignKeyAction.cascade,
        annotations.ForeignKeyAction.setNull,
      );

      final actual = foreignKey.getDefinition();

      const expected = 'FOREIGN KEY (`owner_id`)'
          ' REFERENCES `Person` (`id`)'
          ' ON UPDATE CASCADE'
          ' ON DELETE SET NULL';
      expect(actual, equals(expected));
    });

    test('getDefinition for multiple child and parent columns', () {
      final foreignKey = ForeignKey(
        'Person',
        ['id', 'foo'],
        ['owner_id', 'bar'],
        annotations.ForeignKeyAction.cascade,
        annotations.ForeignKeyAction.setNull,
      );

      final actual = foreignKey.getDefinition();

      const expected = 'FOREIGN KEY (`owner_id`, `bar`)'
          ' REFERENCES `Person` (`id`, `foo`)'
          ' ON UPDATE CASCADE'
          ' ON DELETE SET NULL';
      expect(actual, equals(expected));
    });
  });
}
