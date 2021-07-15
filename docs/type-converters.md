# Type Converters

!!! attention
    This feature is still in an experimental state.
    Please use it with caution and file issues for problems you encounter.

SQLite allows storing values of only a handful types.
Whenever more complex Dart in-memory objects should be stored, there sometimes is the need for converting between Dart and SQLite compatible types.
Dart's `DateTime`, for instance, provides an object-oriented API for handling time.
Objects of this class can simply be represented as `int` values by mapping `DateTime` to its timestamp in milliseconds.
Instead of manually mapping between these types repeatedly, when reading and writing, type converters can be used.
It's sufficient to define the conversion from a database to an in-memory type and vice versa once, which then is reused automatically.

The implementation and usage of the mentioned `DateTime` to `int` converter is described in the following.

1. Create a converter class that implements the abstract `TypeConverter` and supply the in-memory object type and database type as parameterized types.
   This class inherits the `decode()` and `encode()` functions which define the conversion from one to the other type.
```dart
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
```

2. Apply the created type converter to the database by using the `@TypeConverters` annotation and make sure to additionally import the file of your type converter here.
   Importing it in your database file is **always** necessary because the generated code will be `part` of your database file and this is the location where your type converters get instantiated.
```dart
@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Order])
abstract class OrderDatabase extends FloorDatabase {
  OrderDao get orderDao;
}
```

3. Use the non-default `DateTime` type in an entity.
```dart
@entity
class Order {
  @primaryKey
  final int id;

  final DateTime date;

  Order(this.id, this.date);
}
```

---

**Type converters can be applied to**

1. databases
1. DAOs
1. entities/views
1. entity/view fields
1. DAO methods
1. DAO method parameters

The type converter is added to the scope of the element so if you put it on a class, all methods/fields in that class will be able to use the converter.

**The closest type converter wins!**
If you, for example, add a converter on the database level and another one on a DAO method parameter, which takes care of converting the same types, the one declared next to the DAO method parameter will be used.
Please refer to the above list to get more information about the precedence of converters.
