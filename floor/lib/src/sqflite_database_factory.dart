import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// infers factory as nullable without explicit type definition
final DatabaseFactory sqfliteDatabaseFactory = () {
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
  Future<String> getDatabasePath(final String name, {String? path}) async {
    if(path == null){
      path = await this.getDatabasesPath();
    }

    var dir=  Directory(path);

    if (!dir.existsSync()) {
      dir.create(recursive: true);
    }

    return join(dir.path, name);
  }
}
