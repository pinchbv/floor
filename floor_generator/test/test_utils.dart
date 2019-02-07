import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

/// Creates a [LibraryReader] of the [sourceFile].
Future<LibraryReader> resolveCompilationUnit(String sourceFile) async {
  final files = [File(sourceFile)];

  final fileMap = Map<String, String>.fromEntries(files.map(
      (f) => MapEntry('a|lib/${path.basename(f.path)}', f.readAsStringSync())));

  final library = await resolveSources(fileMap, (item) async {
    final assetId = AssetId.parse(fileMap.keys.first);
    return item.libraryFor(assetId);
  });

  return LibraryReader(library);
}

Future<DartType> getDartType(dynamic value) async {
  final source = '''
  library test;
  final value = $value;
  ''';
  return resolveSource(source, (item) async {
    final libraryReader = LibraryReader(await item.findLibraryByName('test'));
    return (libraryReader.allElements.elementAt(1) as VariableElement).type;
  });
}
