import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/writer/writer.dart';

class DatabaseBuilderWriter extends Writer {
  final String _databaseName;

  DatabaseBuilderWriter(final String databaseName)
      : _databaseName = databaseName;

  @nonNull
  @override
  Class write() {
    final databaseBuilderName = '_\$${_databaseName}Builder';

    final nameField = Field((builder) => builder
      ..name = 'name'
      ..type = refer('String')
      ..modifier = FieldModifier.final$);

    final migrationsField = Field((builder) => builder
      ..name = '_migrations'
      ..type = refer('List<Migration>')
      ..modifier = FieldModifier.final$
      ..assignment = const Code('[]'));

    final constructor = Constructor((builder) => builder
      ..requiredParameters.add(Parameter((builder) => builder
        ..toThis = true
        ..name = 'name')));

    final addMigrationsMethod = Method((builder) => builder
      ..name = 'addMigrations'
      ..returns = refer(databaseBuilderName)
      ..body = const Code('''
        _migrations.addAll(migrations);
        return this;
      ''')
      ..docs.add('/// Adds migrations to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'migrations'
        ..type = refer('List<Migration>'))));

    final onConfigureParameter = Parameter((builder) => builder
      ..name = 'onConfigure'
      ..named = true
      ..type = refer('sqflite.OnDatabaseConfigureFn'));

    final onCreateParameter = Parameter((builder) => builder
      ..name = 'onCreate'
      ..named = true
      ..type = refer('sqflite.OnDatabaseCreateFn'));

    final onUpgradeParameter = Parameter((builder) => builder
      ..name = 'onUpgrade'
      ..named = true
      ..type = refer('sqflite.OnDatabaseVersionChangeFn'));

    final buildMethod = Method((builder) => builder
      ..returns = refer('Future<$_databaseName>')
      ..name = 'build'
      ..optionalParameters.addAll([
        onConfigureParameter,
        onCreateParameter,
        onUpgradeParameter,
      ])
      ..modifier = MethodModifier.async
      ..docs.add('/// Creates the database and initializes it.')
      ..body = Code('''
        final database = _\$$_databaseName();
        database.database = await database.open(
          name ?? ':memory:',
          _migrations,
          onConfigure: onConfigure,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
        );
        return database;
      '''));

    return Class((builder) => builder
      ..name = databaseBuilderName
      ..fields.addAll([nameField, migrationsField])
      ..constructors.add(constructor)
      ..methods.addAll([addMigrationsMethod, buildMethod]));
  }
}
