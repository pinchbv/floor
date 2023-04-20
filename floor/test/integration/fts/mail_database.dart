import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqflite;

import 'mail.dart';
import 'mail_dao.dart';

part 'mail_database.g.dart';

@Database(version: 1, entities: [Mail])
abstract class MailDatabase extends FloorDatabase {
  MailDao get mailDao;
}
