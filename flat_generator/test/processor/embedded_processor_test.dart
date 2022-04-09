import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/misc/extension/field_element_extension.dart';
import 'package:flat_generator/processor/embedded_processor.dart';
import 'package:flat_generator/processor/error/embedded_processor_error.dart';
import 'package:flat_generator/processor/field_processor.dart';
import 'package:flat_generator/value_object/embedded.dart';
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
         final String city;
         
         final String street;

         Address(this.city, this.street);
       }
     ''');

    final fieldElement = classElement.fields[2];
    final embeddedClassElement = fieldElement.type.element as ClassElement;
    final actual = EmbeddedProcessor(fieldElement, {}).process();

    final fields = embeddedClassElement.fields
        .map((e) => FieldProcessor(e, null).process())
        .toList();
    final expected = Embedded(fieldElement, 'Address', fields, [], false);
    expect(actual, equals(expected));
  });

  test('Process nested embedded', () async {
    final classElement = await createClassElement('''
       @entity
       class Person {
         @primaryKey
         final int id;
       
         final String name;

         @Embedded('address_')
         final Address address;
       
         Person(this.id, this.name, this.address);
       }

       class Address {
         final String name;
         
         @Embedded('country_')
         final Country country;
         
         final String city;
         
         final String street;
         
         @embedded
         final Coordinate coordinate;
         
         Address(this.name, this.country, this.city, this.street, this.coordinate);
       }
       
       class Country {
         final String name;
         
         Country(this.name);
       }
       
       class Coordinate {
         final double lat;
         
         final double lng;
         
         Coordinate(this.lat, this.lng);
       }
     ''');

    final fieldElement = classElement.fields[2];
    final embeddedClassElement = fieldElement.type.element as ClassElement;
    final actual = EmbeddedProcessor(fieldElement, {}).process();

    final country = EmbeddedProcessor(embeddedClassElement.fields[1], {},
            prefix: 'address_')
        .process();

    final coordinate = EmbeddedProcessor(embeddedClassElement.fields[4], {},
            prefix: 'address_')
        .process();

    final fields = embeddedClassElement.fields
        .where((e) => !e.isEmbedded())
        .map((e) => FieldProcessor(e, null, prefix: 'address_').process())
        .toList();
    final expected =
        Embedded(fieldElement, 'Address', fields, [country, coordinate], false);
    expect(actual, equals(expected));
  });

  test('Throw when there is a cyclic dependency between embedded objects',
      () async {
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
         final String city;
         
         final String street;
         
         @embedded
         final Person creator;

         Address(this.city, this.street, this.creator);
       }
     ''');

    final fieldElement = classElement.fields[2];
    final embeddedClassElement = fieldElement.type.element as ClassElement;

    final processor = EmbeddedProcessor(fieldElement, {});
    expect(
        processor.process,
        throwsInvalidGenerationSourceError(
            EmbeddedProcessorError(embeddedClassElement)
                .possibleCyclicEmbeddedDependency));
  });
}
