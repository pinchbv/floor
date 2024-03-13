import 'package:floor/floor.dart';

enum TaskStatus {
  open('Open'),
  inProgress('In Progress'),
  done('Done');

  final String title;

  const TaskStatus(this.title);
}

enum TaskType {
  bug('Bug'),
  story('Story'),
  task('Task');

  final String title;

  const TaskType(this.title);
}

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String message;

  final bool? isRead;

  final DateTime timestamp;

  final TaskStatus? status;

  final TaskType? type;

  Task(
    this.id,
    this.isRead,
    this.message,
    this.timestamp,
    this.status,
    this.type,
  );

  factory Task.optional({
    int? id,
    DateTime? timestamp,
    String? message,
    bool? isRead,
    TaskStatus? status,
    TaskType? type,
  }) =>
      Task(
        id,
        isRead ?? false,
        message ?? 'empty',
        timestamp ?? DateTime.now(),
        status,
        type,
      );

  @override
  String toString() {
    return 'Task{id: $id, message: $message, read: $isRead, timestamp: $timestamp, status: $status, type: $type}';
  }

  Task copyWith({
    int? id,
    String? message,
    bool? isRead,
    DateTime? timestamp,
    TaskStatus? status,
    TaskType? type,
  }) {
    return Task(
      id ?? this.id,
      isRead ?? this.isRead,
      message ?? this.message,
      timestamp ?? this.timestamp,
      status ?? this.status,
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
          status == other.status &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      message.hashCode ^
      isRead.hashCode ^
      timestamp.hashCode ^
      status.hashCode ^
      type.hashCode;
}

extension TaskExtension on Task {
  String get statusTitle => status?.title ?? 'Empty';

  int get statusIndex => status?.index ?? 0;
}
