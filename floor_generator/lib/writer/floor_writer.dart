// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/writer.dart';

class FloorWriter extends Writer {
  final String _databaseName;

  FloorWriter(final String databaseName) : _databaseName = databaseName;

  @override
  Class write() {
    final databaseBuilderName = '_\$${_databaseName}Builder';

    final databaseBuilderMethod = Method((builder) => builder
      ..name = 'databaseBuilder'
      ..lambda = true
      ..static = true
      ..body = Code('$databaseBuilderName(name)')
      ..returns = refer(databaseBuilderName)
      ..docs.addAll([
        r'/// Creates a database builder for a persistent database.',
        '/// Once a database is built, you should keep a reference to it and re-use it.'
      ])
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'name'
        ..type = refer('String'))));

    final inMemoryDatabaseBuilderMethod = Method((builder) => builder
      ..name = 'inMemoryDatabaseBuilder'
      ..lambda = true
      ..static = true
      ..returns = refer(databaseBuilderName)
      ..docs.addAll([
        r'/// Creates a database builder for an in memory database.',
        '/// Information stored in an in memory database disappears when the process is killed.',
        '/// Once a database is built, you should keep a reference to it and re-use it.'
      ])
      ..body = Code('$databaseBuilderName(null)'));

    return Class((builder) => builder
      ..name = '\$Floor$_databaseName'
      ..methods.addAll([databaseBuilderMethod, inMemoryDatabaseBuilderMethod]));
  }
}
