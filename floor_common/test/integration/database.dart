import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;

import '../test_util/database_factory.dart';
import 'dao/dog_dao.dart';
import 'dao/person_dao.dart';
import 'model/dog.dart';
import 'model/person.dart';

part 'database.g.dart';

@Database(version: 2, entities: [Person, Dog])
abstract class TestDatabase extends FloorDatabase {
  PersonDao get personDao;

  DogDao get dogDao;
}
