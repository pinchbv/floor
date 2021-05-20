import 'package:floor/floor.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) => DateTime.fromMillisecondsSinceEpoch(databaseValue);

  @override
  int encode(DateTime value) => value.millisecondsSinceEpoch;
}
