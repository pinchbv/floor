import 'package:floor/floor.dart';

import 'type_converter.dart';

@entity
class Order {
  @primaryKey
  final int id;

  @TypeConverters([DateTimeToMicrosecondsConverter])
  final DateTime date;

  Order(this.id, this.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ date.hashCode;

  @override
  String toString() {
    return 'Order{id: $id, date: $date}';
  }
}
