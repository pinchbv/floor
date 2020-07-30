import 'package:floor/floor.dart';

class Timestamp {
  @ColumnInfo(name: 'created_at')
  final String createdAt;

  @ColumnInfo(name: 'updated_at')
  final String updatedAt;

  Timestamp({this.createdAt, this.updatedAt});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamp &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => createdAt.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    return 'Task{createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
