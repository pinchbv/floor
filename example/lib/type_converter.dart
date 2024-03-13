import 'package:example/task.dart';
import 'package:floor/floor.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

class TaskTypeConverter extends TypeConverter<TaskType?, String?> {
  @override
  TaskType? decode(String? databaseValue) {
    return databaseValue == null ? null : TaskType.values.byName(databaseValue);
  }

  @override
  String? encode(TaskType? value) {
    return value?.name;
  }
}
