import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/writer.dart';

class DatabaseBuilderContractWriter extends Writer {
  final String _databaseName;

  DatabaseBuilderContractWriter(final String databaseName)
      : _databaseName = databaseName;

  @override
  Class write() {
    final databaseBuilderName = '\$${_databaseName}BuilderContract';

    final addMigrationsMethod = Method((builder) => builder
      ..name = 'addMigrations'
      ..returns = refer(databaseBuilderName)
      ..docs.add('/// Adds migrations to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'migrations'
        ..type = refer('List<Migration>'))));

    final addCallbackMethod = Method((builder) => builder
      ..name = 'addCallback'
      ..returns = refer(databaseBuilderName)
      ..docs.add('/// Adds a database [Callback] to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'callback'
        ..type = refer('Callback'))));

    final buildMethod = Method((builder) => builder
      ..returns = refer('Future<$_databaseName>')
      ..name = 'build'
      ..modifier = MethodModifier.async
      ..docs.add('/// Creates the database and initializes it.'));

    return Class((builder) => builder
      ..name = databaseBuilderName
      ..abstract = true
      ..methods.addAll([
        addMigrationsMethod,
        addCallbackMethod,
        buildMethod,
      ]));
  }
}
