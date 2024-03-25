import 'package:floor_common/floor_common.dart';

@entity
class Order {
  @primaryKey
  final int id;

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
