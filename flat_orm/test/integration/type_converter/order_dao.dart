import 'package:flat_orm/flat_orm.dart';

import 'order.dart';

@dao
abstract class OrderDao {
  @insert
  Future<void> insertOrder(Order order);

  @Query('SELECT * FROM `Order` WHERE date = :date')
  Future<List<Order>> findOrdersByDate(DateTime date);

  @Query('SELECT * FROM `Order` WHERE date IN (:dates)')
  Future<List<Order>> findOrdersByDates(List<DateTime> dates);
}
