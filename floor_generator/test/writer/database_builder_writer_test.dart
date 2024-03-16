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
      class _$FooBarBuilder implements $FooBarBuilderContract {
        _$FooBarBuilder(this.name);
      
        final String? name;
      
        final List<Migration> _migrations = [];

        Callback? _callback;
      
        @override
        $FooBarBuilderContract addMigrations(List<Migration> migrations) {
          _migrations.addAll(migrations);
          return this;
        }

        @override
        $FooBarBuilderContract addCallback(Callback callback) {
          _callback = callback;
          return this;
        }

        @override
        Future<FooBar> build() async {
          final path = name != null
            ? await sqfliteDatabaseFactory.getDatabasePath(name!)
            : ':memory:'; 
          final database = _$FooBar();
          database.database = await database.open(
            path,
            _migrations,
            _callback,
          );
          return database;
        }
      }      
    '''));
  });
}
