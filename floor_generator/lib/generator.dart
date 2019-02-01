import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';

/// Database generator
class FloorGenerator implements Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final database = DatabaseWriter(library).write();

    // TODO generator runs for every file of the project, so this fails without
    if (database == null) {
      return null;
    }

    return database.accept(DartEmitter()).toString();
  }
}
