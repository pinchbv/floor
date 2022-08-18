import 'package:example/task.dart';
import 'package:floor/floor.dart';

@dao
abstract class TaskDao {
  @Query('SELECT * FROM task WHERE id = :id')
  Future<Task?> findTaskById(int id);

  @Query('SELECT * FROM task')
  Future<List<Task>> findAllTasks();

  @Query('SELECT * FROM task')
  Stream<List<Task>> findAllTasksAsStream();

  @Query('SELECT DISTINCT COUNT(message) FROM task')
  Stream<int?> findUniqueMessagesCountAsStream();

  @Query('SELECT DISTINCT COUNT(message) FROM task')
  Future<int?> findUniqueMessagesCount();

  @Query('SELECT DISTINCT message FROM task')
  Stream<List<String>> findUniqueMessagesAsStream();

  @Query('SELECT DISTINCT message FROM task')
  Future<List<String>> findUniqueMessages();

  @Query('SELECT message FROM task')
  Future<List<String>> findAllMessages();

  @Query('SELECT * FROM task WHERE type = :type')
  Stream<List<Task>> findAllTasksByTypeAsStream(TaskType type);

  @insert
  Future<void> insertTask(Task task);

  @insert
  Future<void> insertTasks(List<Task> tasks);

  @update
  Future<void> updateTask(Task task);

  @update
  Future<void> updateTasks(List<Task> task);

  @delete
  Future<void> deleteTask(Task task);

  @delete
  Future<void> deleteTasks(List<Task> tasks);
}
