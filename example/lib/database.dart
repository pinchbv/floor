import 'dart:async';

import 'package:example/date_time_converter.dart';
import 'package:example/task.dart';
import 'package:example/task_dao.dart';
import 'package:example/timestamp.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Task], embeds: [Timestamp])
abstract class FlutterDatabase extends FloorDatabase {
  TaskDao get taskDao;
}
