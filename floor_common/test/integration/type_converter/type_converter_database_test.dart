import 'package:test/test.dart';

import 'order.dart';
import 'order_dao.dart';
import 'order_database.dart';

void main() {
  late OrderDatabase database;
  late OrderDao orderDao;

  setUp(() async {
    database = await $FloorOrderDatabase.inMemoryDatabaseBuilder().build();
    orderDao = database.orderDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('find orders by date', () async {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(123456);
    final order = Order(1, dateTime);
    await orderDao.insertOrder(order);

    final actual = await orderDao.findOrdersByDate(dateTime);

    expect(actual, equals([order]));
  });

  test('find orders by dates', () async {
    final firstOrder = Order(1, DateTime.fromMillisecondsSinceEpoch(123));
    final secondOrder = Order(2, DateTime.fromMillisecondsSinceEpoch(456));
    await orderDao.insertOrder(firstOrder);
    await orderDao.insertOrder(secondOrder);

    final actual = await orderDao.findOrdersByDates([
      firstOrder.date,
      secondOrder.date,
    ]);

    expect(actual, equals([firstOrder, secondOrder]));
  });
}
