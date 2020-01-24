import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// Creates a [LibraryReader] of the [sourceFile].
Future<LibraryReader> resolveCompilationUnit(final String sourceFile) async {
  final files = [File(sourceFile)];

  final fileMap = Map<String, String>.fromEntries(files.map((file) =>
      MapEntry('a|lib/${path.basename(file.path)}', file.readAsStringSync())));

  final library = await resolveSources(fileMap, (item) async {
    final assetId = AssetId.parse(fileMap.keys.first);
    return item.libraryFor(assetId);
  });

  return LibraryReader(library);
}

Future<DartType> getDartType(final dynamic value) async {
  final source = '''
  library test;
  
  final value = $value;
  ''';
  return resolveSource(source, (item) async {
    final libraryReader = LibraryReader(await item.findLibraryByName('test'));
    return (libraryReader.allElements.elementAt(1) as VariableElement).type;
  });
}

Future<DartType> getDartTypeFromString(final String value) {
  return getDartType(value);
}

Future<DartType> getDartTypeWithPerson(String value) async {
  final source = '''
  library test;
  
  import 'package:floor_annotation/floor_annotation.dart';
  
  $value value;
  
  @entity
  class Person {
    @primaryKey
    final int id;
  
    final String name;
  
    Person(this.id, this.name);
  }
  ''';
  return resolveSource(source, (item) async {
    final libraryReader = LibraryReader(await item.findLibraryByName('test'));
    return (libraryReader.allElements.first as PropertyAccessorElement)
        .type
        .returnType;
  });
}

final _dartfmt = DartFormatter();

String _format(final String source) {
  try {
    return _dartfmt.format(source);
  } on FormatException catch (_) {
    return _dartfmt.formatStatement(source);
  }
}

/// Should be invoked in `main()` of every test in `test/**_test.dart`.
void useDartfmt() => EqualsDart.format = _format;

Matcher throwsInvalidGenerationSourceError(
  final InvalidGenerationSourceError error,
) {
  return throwsA(
    const TypeMatcher<InvalidGenerationSourceError>()
        .having((e) => e.message, 'message', error.message)
        .having((e) => e.todo, 'todo', error.todo)
        .having((e) => e.element, 'element', error.element),
  );
}

Future<Dao> createDao(final String methodSignature) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
        $methodSignature
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

  final daoClass = library.classes.firstWhere((classElement) =>
      classElement.hasAnnotation(annotations.dao.runtimeType));

  final entities = library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement).process())
      .toList();

  return DaoProcessor(daoClass, 'personDao', 'TestDatabase', entities)
      .process();
}
