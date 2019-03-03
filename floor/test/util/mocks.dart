import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseExecutor extends Mock implements DatabaseExecutor {}

class MockDatabaseBatch extends Mock implements Batch {}

class MockSqfliteDatabase extends Mock implements Database {}
