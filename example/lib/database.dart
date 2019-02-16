import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database()
abstract class MyDatabase extends FloorDatabase {
  static Future<MyDatabase> openDatabase() async => _$open();

  @Query('SELECT * FROM task WHERE id = :id')
  Future<Task> findTaskById(int id);

  @Query('SELECT * FROM task')
  Future<List<Task>> findAllTasks();

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

@Entity(tableName: 'task')
class Task {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String message;

  Task(this.id, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message;

  @override
  int get hashCode => id.hashCode ^ message.hashCode;

  @override
  String toString() {
    return 'Task{id: $id, message: $message}';
  }
}
