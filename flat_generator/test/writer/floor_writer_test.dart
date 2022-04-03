import 'package:code_builder/code_builder.dart';
import 'package:flat_generator/writer/flat_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('generate flat database builder access class', () async {
    const databaseName = 'FooBar';

    final actual = FlatWriter(databaseName).write();

    expect(actual, equalsDart(r'''
      // ignore: avoid_classes_with_only_static_members
      class $FlatFooBar {
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
