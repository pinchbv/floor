import 'dart:async';

import 'package:example/task.dart';
import 'package:example/task_dao.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [Task])
abstract class FlutterDatabase extends FloorDatabase {
  TaskDao get taskDao;
}
