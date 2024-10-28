import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;


// infers factory as nullable without explicit type definition
final sqlcipher.DatabaseFactory sqfliteDatabaseFactory = () {
  if (kIsWeb) {
    return databaseFactoryFfiWeb;
  } else if (Platform.isAndroid || Platform.isIOS) {
    return sqlcipher.databaseFactory;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  } else {
    throw UnsupportedError(
      'Platform ${Platform.operatingSystem} is not supported by Floor.',
    );
  }
}();

extension DatabaseFactoryExtension on sqlcipher.DatabaseFactory {
  Future<String> getDatabasePath(final String name) async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, name);
  }
}
