import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;

import '../../test_util/database_factory.dart';
import 'order.dart';
import 'order_dao.dart';
import 'type_converter.dart';

part 'order_database.g.dart';

@Database(version: 1, entities: [Order])
@TypeConverters([DateTimeConverter])
abstract class OrderDatabase extends FloorDatabase {
  OrderDao get orderDao;
}
