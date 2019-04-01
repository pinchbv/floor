import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('query all persons', () async {
    final queryMethod = await _generateQueryMethod('''
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAll();
    ''');

    final actual = QueryMethodWriter(queryMethod).write();

    expect(actual, equalsDart('''
      @override
      Future<List<Person>> findAll() async {
        return _queryAdapter.queryList('SELECT * FROM Person', _personMapper);
      }
    '''));
  });
}

Future<QueryMethod> _generateQueryMethod(final String method) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
        $method 
      }
      
      @Entity(tableName: 'person')
      class Person {
        @PrimaryKey()
        final int id;
      
        @ColumnInfo(name: 'custom_name', nullable: false)
        final String name;
      
        Person(this.id, this.name);
      }
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  final daoClass = library.classes.firstWhere((classElement) =>
      typeChecker(annotations.dao.runtimeType)
          .hasAnnotationOfExact(classElement));

  final entities = library.classes
      .where((classElement) =>
          typeChecker(annotations.Entity).hasAnnotationOfExact(classElement))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();

  final dao =
      DaoProcessor(daoClass, 'personDao', 'TestDatabase', entities).process();
  return dao.queryMethods.first;
}
