import 'dart:async';

import 'package:flat_orm/flat_orm.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'mail.dart';
import 'mail_dao.dart';

part 'mail_database.g.dart';

@Database(version: 1, entities: [Mail])
abstract class MailDatabase extends FlatDatabase {
  MailDao get mailDao;
}
