import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final sqfliteDatabaseFactory = () {
  if (Platform.isAndroid || Platform.isIOS) {
    return databaseFactory;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  } else {
    throw UnsupportedError(
      'Platform ${Platform.operatingSystem} is not supported by Floor.',
    );
  }
}();

extension DatabaseFactoryExtension on DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    return join(await getDatabasesPath(), name);
  }
}
