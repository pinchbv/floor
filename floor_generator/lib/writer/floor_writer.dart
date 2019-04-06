import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/writer/writer.dart';

class FloorWriter extends Writer {
  @nonNull
  @override
  Class write() {
    final databaseBuilderMethod = Method((builder) => builder
      ..name = 'databaseBuilder'
      ..lambda = true
      ..static = true
      ..body = const Code(r'_$DatabaseBuilder(name)')
      ..returns = refer(r'_$DatabaseBuilder')
      ..docs.addAll([
        r'/// Creates a _$DatabaseBuilder for a persistent database.',
        '/// Once a database is built, you should keep a reference to it and re-use it.'
      ])
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'name'
        ..type = refer('String'))));

    final inMemoryDatabaseBuilderMethod = Method((builder) => builder
      ..name = 'inMemoryDatabaseBuilder'
      ..lambda = true
      ..static = true
      ..returns = refer(r'_$DatabaseBuilder')
      ..docs.addAll([
        r'/// Creates a _$DatabaseBuilder for an in memory database.',
        '/// Information stored in an in memory database disappears when the process is killed.',
        '/// Once a database is built, you should keep a reference to it and re-use it.'
      ])
      ..body = const Code(r'_$DatabaseBuilder(null)'));

    return Class((builder) => builder
      ..name = r'$Floor'
      ..methods.addAll([databaseBuilderMethod, inMemoryDatabaseBuilderMethod]));
  }
}
