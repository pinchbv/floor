import 'dart:async';

import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'dao/dog_dao.dart';
part 'dao/person_dao.dart';
part 'database.g.dart';
part 'model/address.dart';
part 'model/dog.dart';
part 'model/person.dart';

@Database(version: 2)
abstract class TestDatabase extends FloorDatabase {
  static Future<TestDatabase> openDatabase(List<Migration> migrations) async =>
      _$open(migrations);

  PersonDao get personDao;

  DogDao get dogDao;
}
