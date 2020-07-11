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
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/view.dart';
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
  }, inputId: createAssetId());
}

Future<DartType> getDartTypeFromString(final String value) {
  return getDartType(value);
}

Future<DartType> getDartTypeWithPerson(String value, [int id]) async {
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
  }, inputId: createAssetId(id));
}

Future<DartType> getDartTypeWithName(String value, [int id]) async {
  final source = '''
  library test;
  
  import 'package:floor_annotation/floor_annotation.dart';
  
  $value value;
  
  @DatabaseView("SELECT DISTINCT(name) AS name from person")
  class Name {
    final String name;
  
    Name(this.name);
  }
  ''';
  return resolveSource(source, (item) async {
    final libraryReader = LibraryReader(await item.findLibraryByName('test'));
    return (libraryReader.allElements.first as PropertyAccessorElement)
        .type
        .returnType;
  }, inputId: createAssetId(id));
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

Matcher throwsInvalidGenerationSourceErrorWithMessagePrefix(
  final InvalidGenerationSourceError error,
) {
  return throwsA(
    const TypeMatcher<InvalidGenerationSourceError>()
        .having((e) => e.message, 'message', startsWith(error.message))
        .having((e) => e.todo, 'todo', error.todo)
        .having((e) => e.element, 'element', error.element),
  );
}

Future<Dao> createDao(final String dao) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $dao
      
      $_personEntity
      
      $_nameView
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  }, inputId: createAssetId());

  final daoClass = library.classes.firstWhere((classElement) =>
      classElement.hasAnnotation(annotations.dao.runtimeType));

  final engine = AnalyzerEngine();

  final entities = library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, engine).process())
      .toList();
  final views = library.classes
      .where((classElement) =>
          classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement, engine).process())
      .toList();

  return DaoProcessor(
          daoClass, 'personDao', 'TestDatabase', entities, views, engine)
      .process();
}

Future<Dao> createDaoMethod(final String methodSignature) async {
  return createDao('''
      @dao
      abstract class PersonDao {
        $methodSignature
      }
    ''');
}

Future<ClassElement> createClassElement(final String clazz) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $clazz
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  }, inputId: createAssetId());

  return library.classes.first;
}

Future<Entity> getPersonEntity() async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $_personEntity
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  }, inputId: createAssetId());

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) =>
          EntityProcessor(classElement, AnalyzerEngine()).process())
      .first;
}

extension StringExtension on String {
  Future<MethodElement> asDaoMethodElement() async {
    final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      @dao
      abstract class PersonDao {
        $this 
      }
      
      $_personEntity
    ''', (resolver) async {
      return LibraryReader(await resolver.findLibraryByName('test'));
    }, inputId: createAssetId());

    return library.classes.first.methods.first;
  }
}

Future<AnalyzerEngine> getEngineWithPersonEntity() async {
  final engine = AnalyzerEngine();
  engine.registerEntity(await getPersonEntity());
  return engine;
}

Future<List<Entity>> getEntities([AnalyzerEngine engine]) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $_personEntity
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  }, inputId: createAssetId());

  engine ??= AnalyzerEngine();

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, engine).process())
      .toList();
}

Future<List<View>> getViews([AnalyzerEngine engine]) async {
  final library = await resolveSource('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $_nameView
    ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  }, inputId: createAssetId());

  engine ??= await getEngineWithPersonEntity();

  return library.classes
      .where((classElement) =>
          classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement, engine).process())
      .toList();
}

const _personEntity = '''
  @entity
  class Person {
    @primaryKey
    final int id;
        
    final String name;
        
    Person(this.id, this.name);
  }
''';

const _nameView = '''
  @DatabaseView("SELECT DISTINCT name FROM Person")
  class Name {
    final String name;
  
    Name(this.name);
  }

''';

/// give each created source a unique id to avoid messing up span
/// calculation for error tests. This does not have to be thread-safe as tests
/// are usually executed single-threaded and the ids only have to be different
/// for multiple assets in the same tests.
int _id = 0;
AssetId createAssetId([int id]) {
  id ??= _id++;
  return AssetId('_resolve_source', 'lib/_resolve_source$id.dart');
}
