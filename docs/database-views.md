# Database Views

If you want to define static `SELECT`-statements which return different types than your entities, your best option is to use `@DatabaseView`.
A database view can be understood as a virtual table, which can be queried like a real table.

A database view in floor is defined and used similarly to entities, with the main difference being that access is read-only, which means that update, insert and delete functions are not possible.
Similarly to entities, the class name is used if no `viewName` was set.

```dart
@DatabaseView('SELECT distinct(name) AS name FROM person', viewName: 'name')
class Name {
  final String name;

  Name(this.name);
}
```

Database views do not have any foreign/primary keys or indices. Instead, you should manually define indices which fit to your statement and put them into the `@Entity` annotation of the involved entities.

Setters, getters and static fields are automatically ignored (like in entities), you can specify additional fields to ignore by annotating them with `@ignore`.

After defining a database view in your code, you have to add it to your database by adding it to the `views` field of the `@Database` annotation:

```dart
@Database(version: 1, entities: [Person], views: [Name])
abstract class AppDatabase extends FloorDatabase {
  // DAO getters
}
```

You can then query the view via a DAO function like an entity.

It is possible for DatabaseViews to inherit common fields from a base class, just like in entities.

!!! attention
    It is now possible to return a `Stream` object from a DAO method which queries a database view. But it will fire on **any**
    `@update`, `@insert`, `@delete` events in the whole database, which can get quite taxing on the runtime. Please add it only if you know what you are doing!
    This is mostly due to the complexity of detecting which entities are involved in a database view.
