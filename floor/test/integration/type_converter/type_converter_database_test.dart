import 'package:flutter_test/flutter_test.dart';

import 'order.dart';
import 'order_dao.dart';
import 'order_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OrderDatabase database;
  OrderDao orderDao;

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
}
