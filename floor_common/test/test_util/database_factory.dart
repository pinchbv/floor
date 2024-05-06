import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// infers factory as nullable without explicit type definition
final DatabaseFactory sqfliteDatabaseFactory = () {
  sqfliteFfiInit();
  return databaseFactoryFfi;
}();

extension DatabaseFactoryExtension on DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    final databasesPath = await this.getDatabasesPath();
    return join(databasesPath, name);
  }
}