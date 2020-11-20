// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/floor_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('generate floor database builder access class', () async {
    const databaseName = 'FooBar';

    final actual = FloorWriter(databaseName).write();

    expect(actual, equalsDart(r'''
      class $FloorFooBar {
        /// Creates a database builder for a persistent database.
        /// Once a database is built, you should keep a reference to it and re-use it.
        static _$FooBarBuilder databaseBuilder(String name) =>
            _$FooBarBuilder(name);
      
        /// Creates a database builder for an in memory database.
        /// Information stored in an in memory database disappears when the process is killed.
        /// Once a database is built, you should keep a reference to it and re-use it.
        static _$FooBarBuilder inMemoryDatabaseBuilder() =>
            _$FooBarBuilder(null);
      }   
    '''));
  });
}
