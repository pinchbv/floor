import 'dart:async';

import 'package:floor/floor.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqflite;

import 'order.dart';
import 'order_dao.dart';
import 'type_converter.dart';

part 'order_database.g.dart';

@Database(version: 1, entities: [Order])
@TypeConverters([DateTimeConverter])
abstract class OrderDatabase extends FloorDatabase {
  OrderDao get orderDao;
}
