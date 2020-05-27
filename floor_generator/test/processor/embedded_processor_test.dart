import 'package:floor_generator/processor/embedded_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:floor_generator/extension/field_element_extension.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process embedded', () async {
    final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;

        @embedded
        final Address address;
      
        Person(this.id, this.name, this.address);
      }

      class Address {
        final String street;

        Address(this.street);
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    const name = 'Person';
    final fields = classElement.fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field).process())
        .toList();
    final embeddeds = classElement.fields
        .where((fieldElement) => fieldElement.isEmbedded)
        .map((embedded) => EmbeddedProcessor(embedded).process())
        .toList();
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor =
        "Person(row['id'] as int, row['name'] as String, Address(row['street'] as String))";
    final expected = Entity(
      classElement,
      name,
      fields,
      embeddeds,
      primaryKey,
      foreignKeys,
      indices,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process named embedded', () async {
    final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;

        @embedded
        final Address address;
      
        Person(this.id, this.name, {this.address});
      }

      class Address {
        final String street;

        Address(this.street);
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    const name = 'Person';
    final fields = classElement.fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field).process())
        .toList();
    final embeddeds = classElement.fields
        .where((fieldElement) => fieldElement.isEmbedded)
        .map((embedded) => EmbeddedProcessor(embedded).process())
        .toList();
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor =
        "Person(row['id'] as int, row['name'] as String, address: Address(row['street'] as String))";
    final expected = Entity(
      classElement,
      name,
      fields,
      embeddeds,
      primaryKey,
      foreignKeys,
      indices,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process nested embedded', () async {
    final classElement = await createClassElement('''
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;

        @embedded
        final Address address;
      
        Person(this.id, this.name, this.address);
      }

      class Address {
        @embedded
        final Street street;

        Address(this.street);
      }

      class Street {
        final String street;

        Street(this.street);
      }
    ''');

    final actual = EntityProcessor(classElement).process();

    const name = 'Person';
    final fields = classElement.fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((fieldElement) => FieldProcessor(fieldElement).process())
        .toList();
    final embeddeds = classElement.fields
        .where((fieldElement) => fieldElement.isEmbedded)
        .map((fieldElement) => EmbeddedProcessor(fieldElement).process())
        .toList();
    final primaryKey = PrimaryKey([fields[0]], false);
    const foreignKeys = <ForeignKey>[];
    const indices = <Index>[];
    const constructor =
        "Person(row['id'] as int, row['name'] as String, Address(Street(row['street'] as String)))";
    final expected = Entity(
      classElement,
      name,
      fields,
      embeddeds,
      primaryKey,
      foreignKeys,
      indices,
      constructor,
    );
    expect(actual, equals(expected));
  });
}
