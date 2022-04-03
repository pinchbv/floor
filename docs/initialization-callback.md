# Initialization Callback

In order to hook into Flat's database initialization process, `Callback` should be used.
It allows the invocation of three separate callbacks which are triggered when the database has been

- initialized for the first time (`onCreate`).
- opened (`onOpen`).
- upgraded (`onUpgrade`).

Each callback is optional.

Their usage can be seen in the following snippet.

```dart
final callback = Callback(
   onCreate: (database, version) { /* database has been created */ },
   onOpen: (database) { /* database has been opened */ },
   onUpgrade: (database, startVersion, endVersion) { /* database has been upgraded */ },
);

final database = await $FlatAppDatabase
    .databaseBuilder('app_database.db')
    .addCallback(callback)
    .build();
```
