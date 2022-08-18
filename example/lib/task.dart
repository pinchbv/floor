import 'package:floor/floor.dart';

enum TaskType {
  open('Open'),
  inProgress('In Progress'),
  done('Done');

  final String title;

  const TaskType(this.title);
}

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String message;

  final bool isRead;

  final DateTime timestamp;

  final TaskType type;

  Task(this.id, this.isRead, this.message, this.timestamp, this.type);

  factory Task.optional({
    int? id,
    DateTime? timestamp,
    String? message,
    bool? isRead,
    TaskType? type,
  }) =>
      Task(
        id,
        isRead ?? false,
        message ?? 'empty',
        timestamp ?? DateTime.now(),
        type ?? TaskType.open,
      );

  @override
  String toString() {
    return 'Task{id: $id, message: $message, read: $isRead, timestamp: $timestamp, type: $type}';
  }

  Task copyWith({
    int? id,
    String? message,
    bool? isRead,
    DateTime? timestamp,
    TaskType? type,
  }) {
    return Task(
      id ?? this.id,
      isRead ?? this.isRead,
      message ?? this.message,
      timestamp ?? this.timestamp,
      type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message &&
          isRead == other.isRead &&
          timestamp == other.timestamp &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      message.hashCode ^
      isRead.hashCode ^
      timestamp.hashCode ^
      type.hashCode;
}
