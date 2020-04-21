import 'package:floor/floor.dart';

import 'order.dart';

@dao
abstract class OrderDao {
  @insert
  Future<void> insertOrder(Order order);

  @update
  Future<void> updateOrder(Order order);

  @delete
  Future<void> deleteOrder(Order order);

  @Query('SELECT * FROM `Order` WHERE id = :id')
  Future<Order> findOrderById(int id);

  @Query('SELECT * FROM `Order` WHERE date = :date')
  Future<List<Order>> findOrdersByDate(DateTime date);

  @Query('SELECT * FROM `Order`')
  Future<List<Order>> findAllOrders();
}
