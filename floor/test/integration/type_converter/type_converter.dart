import 'package:floor/floor.dart';

class DateTimeToIntConverter extends TypeConverter<DateTime, int> {
  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }

  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }
}

class DateTimeToMicrosecondsConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMicrosecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.microsecondsSinceEpoch;
  }
}

