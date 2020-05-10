import 'dart:io' show Platform;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite_flutter;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

final floorDatabaseFactory = _getDatabaseFactory();

// TODO name
extension Foo on DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    return join(await getDatabasesPath(), name);
  }
}

DatabaseFactory _getDatabaseFactory() {
  if (Platform.isAndroid || Platform.isIOS) {
    return sqflite_flutter.databaseFactory;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqflite_ffi.sqfliteFfiInit();
    return sqflite_ffi.databaseFactoryFfi;
  } else {
    throw UnsupportedError(
      'Platform ${Platform.operatingSystem} is not supported by Floor.',
    );
  }
}
