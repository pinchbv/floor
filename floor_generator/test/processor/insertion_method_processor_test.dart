import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/insertion_method_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  test('Collects on conflict strategy', () async {
    final insertionMethod = await '''
      @Insert(onConflict: OnConflictStrategy.replace)
      Future<void> insertPerson(Person person);
    '''
        .asMethodElement();
    final entities = await _getEntities();

    final actual = InsertionMethodProcessor(insertionMethod, entities)
        .process()
        .onConflict;

    expect(actual, equals('OnConflictStrategy.replace'));
  });
}

// TODO #228 extract?
extension on String {
  Future<MethodElement> asMethodElement() async {
    final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
        $this 
      }
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''', (resolver) async {
      return LibraryReader(await resolver.findLibraryByName('test'));
    });

    return library.classes.first.methods.first;
  }
}

// TODO
Future<List<Entity>> _getEntities() async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @entity
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();
}
