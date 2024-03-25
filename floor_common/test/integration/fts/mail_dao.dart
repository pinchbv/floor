import 'package:floor_common/floor_common.dart';

import 'mail.dart';

@dao
abstract class MailDao {
  @Query('SELECT * FROM mail WHERE rowid = :id')
  Future<Mail?> findMailById(int id);

  @Query('SELECT * FROM mail WHERE text match :key')
  Future<List<Mail>> findMailByKey(String key);

  @Query('SELECT * FROM mail')
  Future<List<Mail>> findAllMails();

  @Query('SELECT * FROM mail')
  Stream<List<Mail>> findAllMailsAsStream();

  @insert
  Future<void> insertMail(Mail mailInfo);

  @insert
  Future<void> insertMails(List<Mail> mailInfo);

  @update
  Future<void> updateMail(Mail mailInfo);

  @update
  Future<void> updateMails(List<Mail> mailInfo);

  @delete
  Future<void> deleteMail(Mail mailInfo);

  @delete
  Future<void> deleteMails(List<Mail> mailInfo);
}
