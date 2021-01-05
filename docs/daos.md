# Data Access Objects

These components are responsible for managing access to the underlying SQLite database and are defined as abstract classes with method signatures and query statements.
DAO classes can use inherited methods by implementing and extending classes while also using mixins.

```dart
@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person> findPersonById(int id);

  @insert
  Future<void> insertPerson(Person person);
}
```

## Queries
Method signatures turn into query methods by adding the `@Query()` annotation with the query in parenthesis to them.
Be patient about the correctness of your SQL statements.
They are only partly validated while generating the code.
These queries have to return either a `Future` or a `Stream` of an entity or `void`.
Returning `Future<void>` comes in handy whenever you want to delete the full content of a table, for instance.
Some query method examples can be seen in the following.

```dart
@Query('SELECT * FROM Person WHERE id = :id')
Future<Person> findPersonById(int id);

@Query('SELECT * FROM Person WHERE id = :id AND name = :name')
Future<Person> findPersonByIdAndName(int id, String name);

@Query('SELECT * FROM Person')
Future<List<Person>> findAllPersons(); // select multiple items

@Query('SELECT * FROM Person')
Stream<List<Person>> findAllPersonsAsStream(); // stream return

@Query('DELETE FROM Person')
Future<void> deleteAllPersons(); // query without returning an entity

@Query('SELECT * FROM Person WHERE id IN (:ids)')
Future<List<Person>> findPersonsWithIds(List<int> ids); // query with IN clause
```

Query arguments, when using SQLite's `LIKE` operator, have to be supplied by the input of a method.
It's not possible to define a pattern matching argument like `%foo%` in the query itself.

```dart
// dao
@Query('SELECT * FROM Person WHERE name LIKE :name')
Future<List<Person>> findPersonsWithNamesLike(String name);

// usage
final name = '%foo%';
await dao.findPersonsWithNamesLike(name);
```

## Data Changes
Use the `@insert`, `@update` and `@delete` annotations for inserting and changing persistent data.
All these methods accept single or multiple entity instances.

### Insert

`@insert` marks a method as an insertion method.
When using the capitalized `@Insert` you can specify a conflict strategy.
Else it just defaults to aborting the insert.
These methods can return a `Future` of either `void`, `int` or `List<int>`.
- `void` return nothing
- `int` return primary key of inserted item
- `List<int>` return primary keys of inserted items

```dart
@Insert(onConflict: OnConflictStrategy.rollback)
Future<void> insertPerson(Person person);

@insert
Future<List<int>> insertPersons(List<Person> persons);
```

### Update

`@update` marks a method as an update method.
When using the capitalized `@Update` you can specify a conflict strategy.
Else it just defaults to aborting the update.
These methods can return a `Future` of either `void` or `int`.
- `void` return nothing
- `int` return number of changed rows

```dart
@Update(onConflict: OnConflictStrategy.replace)
Future<void> updatePerson(Person person);

@update
Future<int> updatePersons(List<Person> persons);
```

### Delete

`@delete` marks a method as a deletion method.
These methods can return a `Future` of either `void` or `int`.
- `void` return nothing
- `int` return number of deleted rows

```dart
@delete
Future<void> deletePerson(Person person);

@delete
Future<int> deletePersons(List<Person> persons);
```

## Streams
As already mentioned, queries cannot only return values once when called but also continuous streams of query results.
The returned streams keep you in sync with the changes happening in the database tables.
This feature plays well with the `StreamBuilder` widget which accepts a stream of values and rebuilds itself whenever there is a new emission.

These methods return broadcast streams and thus, can have multiple listeners.
```dart
// definition
@Query('SELECT * FROM Person')
Stream<List<Person>> findAllPersonsAsStream();

// usage
StreamBuilder<List<Person>>(
  stream: dao.findAllPersonsAsStream(),
  builder: (BuildContext context, AsyncSnapshot<List<Person>> snapshot) {
    // do something with the values here
  },
);
```

!!! attention
    - Only methods annotated with `@insert`, `@update` and `@delete` trigger `Stream` emissions.
      Inserting data by using the `@Query()` annotation doesn't.
    - It is now possible to return a `Stream` if the function queries a database view. But it will fire on **any**
      `@update`, `@insert`, `@delete` events in the whole database, which can get quite taxing on the runtime. Please add it only if you know what you are doing!
      This is mostly due to the complexity of detecting which entities are involved in a database view.
    - Functions returning a stream of single items such as `Stream<Person>` do not emit when there is no query result.

## Transactions
Whenever you want to perform some operations in a transaction you have to add the `@transaction` annotation to the method.
It's also required to add the `async` modifier. These methods have to return a `Future`.

```dart
@transaction
Future<void> replacePersons(List<Person> persons) async {
  await deleteAllPersons();
  await insertPersons(persons);
}
```

## Inheritance
Data access object classes support inheritance as shown in the following.
There is no limit to inheritance levels and thus, each abstract parent can have another abstract parent.
Bear in mind that only abstract classes allow method signatures without an implementation body and thereby, make sure to position your to-be-inherited methods in an abstract class and extend this class with your DAO.

```dart
@dao
abstract class PersonDao extends AbstractDao<Person> {
  @Query('SELECT * FROM Person WHERE id = :id')
  Future<Person> findPersonById(int id);
}

abstract class AbstractDao<T> {
  @insert
  Future<void> insertItem(T item);
}

// usage
final person = Person(1, 'Simon');
await personDao.insertItem(person);

final result = await personDao.findPersonById(1);
```
