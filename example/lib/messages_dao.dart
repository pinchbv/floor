import 'package:example/task.dart';
import 'package:floor/floor.dart';

@dao
abstract class MessagesDao {

  @Query('SELECT * FROM messages')
  Future<List<Message>> findAlMessages();
}
