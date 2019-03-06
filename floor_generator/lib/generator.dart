import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';

/// Database generator
class FloorGenerator implements Generator {
  @override
  FutureOr<String> generate(
    final LibraryReader library,
    final BuildStep buildStep,
  ) {
    final database = DatabaseWriter(library).write();
    if (database == null) return null;

    return database.accept(DartEmitter()).toString();
  }
}
