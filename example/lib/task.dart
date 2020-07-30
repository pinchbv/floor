import 'package:example/timestamp.dart';
import 'package:floor/floor.dart';

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String message;

  @Embedded(prefix: 'time_')
  final Timestamp timestamp;

  Task(this.id, this.message, this.timestamp);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message;

  @override
  int get hashCode => id.hashCode ^ message.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'Task{id: $id, message: $message, timestamp: $timestamp}';
  }
}
