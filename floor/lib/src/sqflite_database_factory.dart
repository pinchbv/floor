import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_common_ffi;

// infers factory as nullable without explicit type definition
final sqflite.DatabaseFactory sqfliteDatabaseFactory = () {
  if (Platform.isAndroid || Platform.isIOS) {
    return sqflite.databaseFactory;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqflite_common_ffi.sqfliteFfiInit();
    return sqflite_common_ffi.databaseFactoryFfi;
  } else {
    throw UnsupportedError(
      'Platform ${Platform.operatingSystem} is not supported by Floor.',
    );
  }
}();

extension DatabaseFactoryExtension on sqflite.DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, name);
  }
}
