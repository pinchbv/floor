// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseExecutor extends Mock implements DatabaseExecutor {}

class MockDatabaseBatch extends Mock implements Batch {}

class MockSqfliteDatabase extends Mock implements Database {}

class MockStreamController<T> extends Mock implements StreamController<T> {}
