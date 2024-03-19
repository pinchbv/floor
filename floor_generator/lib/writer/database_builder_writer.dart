import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/writer/writer.dart';

class DatabaseBuilderWriter extends Writer {
  final String _databaseName;

  DatabaseBuilderWriter(final String databaseName)
      : _databaseName = databaseName;

  @override
  Class write() {
    final databaseBuilderName = '_\$${_databaseName}Builder';
    final databaseBuilderContractRefer = refer(
      '\$${_databaseName}BuilderContract',
    );

    final nameField = Field((builder) => builder
      ..name = 'name'
      ..type = refer('String?')
      ..modifier = FieldModifier.final$);

    final migrationsField = Field((builder) => builder
      ..name = '_migrations'
      ..type = refer('List<Migration>')
      ..modifier = FieldModifier.final$
      ..assignment = const Code('[]'));

    final callbackField = Field((builder) => builder
      ..name = '_callback'
      ..type = refer('Callback?'));

    final constructor = Constructor((builder) => builder
      ..requiredParameters.add(Parameter((builder) => builder
        ..toThis = true
        ..name = 'name')));

    final addMigrationsMethod = Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..name = 'addMigrations'
      ..returns = databaseBuilderContractRefer
      ..body = const Code('''
        _migrations.addAll(migrations);
        return this;
      ''')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'migrations'
        ..type = refer('List<Migration>'))));

    final addCallbackMethod = Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..name = 'addCallback'
      ..returns = databaseBuilderContractRefer
      ..body = const Code('''
        _callback = callback;
        return this;
      ''')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'callback'
        ..type = refer('Callback'))));

    final buildMethod = Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer('Future<$_databaseName>')
      ..name = 'build'
      ..modifier = MethodModifier.async
      ..body = Code('''
        final path = name != null
          ? await sqfliteDatabaseFactory.getDatabasePath(name!)
          : ':memory:';
        final database = _\$$_databaseName();
        database.database = await database.open(
          path,
          _migrations,
          _callback,
        );
        return database;
      '''));

    return Class((builder) => builder
      ..name = databaseBuilderName
      ..implements.addAll([
        databaseBuilderContractRefer,
      ])
      ..fields.addAll([
        nameField,
        migrationsField,
        callbackField,
      ])
      ..constructors.add(constructor)
      ..methods.addAll([
        addMigrationsMethod,
        addCallbackMethod,
        buildMethod,
      ]));
  }
}
