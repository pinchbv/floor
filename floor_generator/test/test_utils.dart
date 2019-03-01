import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
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
