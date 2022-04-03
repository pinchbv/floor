# In Memory Database

To instantiate an in-memory database, use the static `inMemoryDatabaseBuilder()` method of the generated `$FlatAppDatabase` class instead of `databaseBuilder()`.

```dart
final database = await $FlatAppDatabase.inMemoryDatabaseBuilder().build();
```
