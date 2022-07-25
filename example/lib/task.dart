import 'package:floor/floor.dart';

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String message;

  final DateTime timestamp;

  Task(this.id, this.message, this.timestamp);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message &&
          timestamp == other.timestamp;

  @override
  int get hashCode => id.hashCode ^ message.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'Task{id: $id, message: $message, timestamp: $timestamp}';
  }
}

@DatabaseView('SELECT message as message FROM task', viewName: 'messages')
class Message {
  final String message;

  Message(this.message);
}
