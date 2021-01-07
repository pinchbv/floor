import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task.g.dart';

@Entity(mapFromJson: true)
@JsonSerializable()
class Task {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String message;

  String mapFromJson;

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

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
