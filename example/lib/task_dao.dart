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

  @rawQuery
  Stream<List<Task>> rawQueryTasksAsStream(SQLiteQuery query);

  Stream<List<Task>> findYesterdaysTasksByMessageAsStream(String message) {
    final timestamp = DateTime.now()
        .subtract(
          const Duration(days: 1),
        )
        .millisecondsSinceEpoch;
    return rawQueryTasksAsStream(SQLiteQuery(
        'SELECT * FROM task WHERE timestamp > ?1 AND message == ?2',
        arguments: [
          timestamp,
          message,
        ]));
  }

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
