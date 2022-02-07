import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';

extension DatabaseFactoryExtension on DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    final databasesPath = await this.getDatabasesPath();
    return join(databasesPath, name);
  }
}
