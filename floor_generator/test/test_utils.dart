import 'dart:io';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart' hide FunctionType;
import 'package:dart_style/dart_style.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

final targetLanguageVersion = Version(3, 7, 0);

/// Creates a [LibraryReader] of the [sourceFile].
Future<LibraryReader> resolveCompilationUnit(final String sourceFile) async {
  final files = [File(sourceFile)];

  final fileMap = Map<String, String>.fromEntries(
      files.map((file) => MapEntry('a|lib/${path.basename(file.path)}', file.readAsStringSync())));

  final library = await resolveSources(fileMap, (item) async {
    final assetId = AssetId.parse(fileMap.keys.first);
    return item.libraryFor(assetId);
  });

  return LibraryReader(library);
}

Future<DartType> getDartType(final dynamic value) async {
  return getDartTypeFromDeclaration('final value = $value');
}

Future<DartType> getDartTypeFromString(final String value) {
  return getDartType(value);
}

Future<LibraryReader> getLibraryReader(String source) async => resolveSource(
      source,
      readAllSourcesFromFilesystem: true,
      (resolver) async => resolver
          .findLibraryByName('test')
          .then((value) => ArgumentError.checkNotNull(value))
          .then((value) => LibraryReader(value)),
    );

Future<DartType> getDartTypeWithPerson(String value) async {
  final libraryReader = await getLibraryReader('''
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
  ''');

  return (libraryReader.allElements.elementAt(2) as GetterElement).type.returnType;
}

Future<DartType> getDartTypeWithName(String value) async {
  final libraryReader = await getLibraryReader('''
  library test;
  
  import 'package:floor_annotation/floor_annotation.dart';
  
  $value value;
  
  @DatabaseView("SELECT DISTINCT(name) AS name from person")
  class Name {
    final String name;
  
    Name(this.name);
  }
  ''');

  return (libraryReader.allElements.elementAt(2) as GetterElement).type.returnType;
}

Future<DartType> getDartTypeFromDeclaration(final String declaration) async {
  final libraryReader = await getLibraryReader('''
  library test;
  import 'dart:typed_data';
  
  $declaration;
  ''');

  return (libraryReader.allElements.elementAt(1) as GetterElement).type.returnType;
}

final _dartfmt = DartFormatter(languageVersion: targetLanguageVersion);

String _format(final String source) {
  try {
    return _dartfmt.format(source);
  } on FormatException catch (_) {
    return _dartfmt.formatStatement(source);
  }
}

/// Should be invoked in `main()` of every test in `test/**_test.dart`.
void useDartfmt() => EqualsDart.format = _format;

Matcher throwsInvalidGenerationSourceError([
  final InvalidGenerationSourceError? error,
]) {
  const typeMatcher = TypeMatcher<InvalidGenerationSourceError>();
  if (error == null) {
    return throwsA(typeMatcher);
  } else {
    return throwsA(
      typeMatcher
          .having((e) => e.message, 'message', error.message)
          .having((e) => e.todo, 'todo', error.todo)
          .having((e) => e.element, 'element', error.element),
    );
  }
}

Matcher throwsProcessorError([
  final ProcessorError? error,
]) {
  const typeMatcher = TypeMatcher<ProcessorError>();
  if (error == null) {
    return throwsA(typeMatcher);
  } else {
    return throwsA(
      typeMatcher
          .having((e) => e.message, 'message', error.message)
          .having((e) => e.todo, 'todo', error.todo)
          .having((e) => e.element, 'element', error.element),
    );
  }
}

Matcher throwsUnresolvedAnnotationException() {
  return throwsA(isA<UnresolvedAnnotationException>());
}

Future<Dao> createDao(final String methodSignature) async {
  final libraryReader = await getLibraryReader('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      import 'dart:typed_data';
      
      @dao
      abstract class PersonDao {
        $methodSignature
      }
      
      $characterType
      
      $_personEntity
      
      $_nameView
      ''');

  final daoClass =
      libraryReader.classes.firstWhere((classElement) => classElement.hasAnnotation(annotations.dao.runtimeType));

  final entities = libraryReader.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, {}).process())
      .toList();
  final views = libraryReader.classes
      .where((classElement) => classElement.hasAnnotation(annotations.DatabaseView))
      .map((classElement) => ViewProcessor(classElement, {}).process())
      .toList();

  return DaoProcessor(daoClass, 'personDao', 'TestDatabase', entities, views, {}).process();
}

Future<ClassElement2> createClassElement(final String clazz) async {
  final libraryReader = await getLibraryReader('''
      library test;
      
      import 'dart:typed_data';
      import 'package:floor_annotation/floor_annotation.dart';
      
      $clazz
      ''');

  return libraryReader.classes.first;
}

extension StringTestExtension on String {
  Future<DartType> asDartType() async {
    return getDartTypeFromString(this);
  }

  Future<ClassElement2> asClassElement() async {
    final library = await getLibraryReader('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      
      $this
      ''');

    return library.classes.first;
  }
}

Future<Entity> getPersonEntity() async {
  final library = await getLibraryReader('''
      library test;
      
      import 'package:floor_annotation/floor_annotation.dart';
      import 'dart:typed_data';
      
      $_personEntity
    ''');

  return library.classes
      .where((classElement) => classElement.hasAnnotation(annotations.Entity))
      .map((classElement) => EntityProcessor(classElement, {}).process())
      .first;
}

extension StringExtension on String {
  Future<MethodElement2> asDaoMethodElement() async {
    final library = await getLibraryReader('''
      library test;
            
      import 'package:floor_annotation/floor_annotation.dart';
      import 'dart:typed_data';
      
      @dao
      abstract class PersonDao {
        $this 
      }
      
      $_personEntity
    ''');

    return library.classes.first.methods2.first;
  }
}

const _personEntity = '''
  @entity
  class Person {
    @primaryKey
    final int id;
        
    final String name;
    
    final double weight;
    
    final bool admin;
    
    final Uint8List avatar;
        
    Person(this.id, this.name, this.weight, this.admin, this.avatar);
  }
''';

const _nameView = '''
  @DatabaseView("SELECT name FROM Person")
  class Name {
    final String name;
  
    Name(this.name);
  }

''';

const characterType = '''
  enum CharacterType { generous, honest, faithful, faithful, loving, kind, sincere }
''';
