// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_database.dart';

// **************************************************************************
// FlatGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FlatOrderDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$OrderDatabaseBuilder databaseBuilder(String name) =>
      _$OrderDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$OrderDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$OrderDatabaseBuilder(null);
}

class _$OrderDatabaseBuilder {
  _$OrderDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$OrderDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$OrderDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<OrderDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$OrderDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$OrderDatabase extends OrderDatabase {
  _$OrderDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  OrderDao? _orderDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Order` (`id` INTEGER NOT NULL, `date` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  OrderDao get orderDao {
    return _orderDaoInstance ??= _$OrderDao(database, changeListener);
  }
}

class _$OrderDao extends OrderDao {
  _$OrderDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _orderInsertionAdapter = InsertionAdapter(
            database,
            'Order',
            (Order item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Order> _orderInsertionAdapter;

  @override
  Future<List<Order>> findOrdersByDate(DateTime date) async {
    return _queryAdapter.queryList('SELECT * FROM `Order` WHERE date = ?1',
        mapper: (Map<String, Object?> row) => Order(
            row['id'] as int, _dateTimeConverter.decode(row['date'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<Order>> findOrdersByDates(List<DateTime> dates) async {
    const offset = 1;
    final _sqliteVariablesForDates =
        Iterable<String>.generate(dates.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM `Order` WHERE date IN (' +
            _sqliteVariablesForDates +
            ')',
        mapper: (Map<String, Object?> row) => Order(
            row['id'] as int, _dateTimeConverter.decode(row['date'] as int)),
        arguments: [
          ...dates.map((element) => _dateTimeConverter.encode(element))
        ]);
  }

  @override
  Future<void> insertOrder(Order order) async {
    await _orderInsertionAdapter.insert(order, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
