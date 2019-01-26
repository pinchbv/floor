import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writers/database_writer.dart';
import 'package:source_gen/source_gen.dart';

/// Database generator
class FloorGenerator implements Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final database = DatabaseWriter(library).write();
    return database.accept(DartEmitter()).toString();
  }
}
