import 'dart:async';

import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/dog_dao.dart';
import 'dao/person_dao.dart';
import 'model/dog.dart';
import 'model/person.dart';

part 'database.g.dart';

@Database(version: 2, entities: [Person, Dog])
abstract class TestDatabase extends FloorDatabase {
  static Future<TestDatabase> openDatabase(List<Migration> migrations) async =>
      _$open(migrations);

  PersonDao get personDao;

  DogDao get dogDao;
}
