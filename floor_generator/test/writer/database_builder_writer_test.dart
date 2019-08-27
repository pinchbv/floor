import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/database_builder_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('generate database builder', () async {
    const databaseName = 'FooBar';

    final actual = DatabaseBuilderWriter(databaseName).write();

    expect(actual, equalsDart(r'''
      class _$FooBarBuilder {
        _$FooBarBuilder(this.name);
      
        final String name;
      
        final List<Migration> _migrations = [];
      
        /// Adds migrations to the builder.
        _$FooBarBuilder addMigrations(List<Migration> migrations) {
          _migrations.addAll(migrations);
          return this;
        }
      
        /// Creates the database and initializes it.
        Future<FooBar> build(
            {sqflite.OnDatabaseConfigureFn onConfigure,
            sqflite.OnDatabaseCreateFn onCreate,
            sqflite.OnDatabaseVersionChangeFn onUpgrade}) async {
          final database = _$FooBar();
          database.database = await database.open(
            name ?? ':memory:',
            _migrations,
            onConfigure: onConfigure,
            onCreate: onCreate,
            onUpgrade: onUpgrade,
          );
          return database;
        }
      }      
    '''));
  });
}
