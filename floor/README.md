# Floor
**A supportive SQLite abstraction for your Flutter applications (iOS, Android and macOS)**

The Floor library provides a lightweight SQLite abstraction with automatic mapping between in-memory objects and database rows while still offering full control of the database with the use of SQL.

This package is still in an early phase and the API will likely change.

[![pub package](https://img.shields.io/pub/v/floor.svg)](https://pub.dartlang.org/packages/floor)
[![build status](https://github.com/vitusortner/floor/workflows/Continuous%20integration/badge.svg)](https://github.com/vitusortner/floor/actions)
[![codecov](https://codecov.io/gh/vitusortner/floor/branch/develop/graph/badge.svg)](https://codecov.io/gh/vitusortner/floor)

### Table of Contents

1. [Quick Start](#quick-start)
1. [Architecture](#architecture)
1. [Entities](#entities)
    1. [Supported Types](#supported-types)
    1. [Foreign Keys](#foreign-keys)
    1. [Primary Keys](#primary-keys)
    1. [Indices](#indices)
    1. [Ignoring Fields](#ignoring-fields)
1. [Database Views](#database-views)
1. [Data Access Objects](#data-access-objects)
    1. [Queries](#queries)
    1. [Data Changes](#data-changes)
    1. [Streams](#streams)
    1. [Transactions](#transactions)
1. [Migrations](#migrations)
1. [In-Memory Database](#in-memory-database)
1. [Initialization Callback](#initialization-callback)
1. [Testing](#testing)
1. [Examples](#examples)
1. [Naming](#naming)
1. [Bugs and Feedback](#bugs-and-feedback)
1. [License](#license)

## Quick Start
1. Add the runtime dependency `floor` as well as the generator `floor_generator` to your `pubspec.yaml`.
    The third dependency is `build_runner` which has to be included as a dev dependency just like the generator.

    - `floor` holds all the code you are going to use in your application.

    - `floor_generator` includes the code for generating the database classes.

    - `build_runner` enables a concrete way of generating source code files.

    ````yaml
    dependencies:
      flutter:
        sdk: flutter
      floor: ^0.12.0

    dev_dependencies:
      floor_generator: ^0.12.0
      build_runner: ^1.7.3
    ````

1. Create an **Entity**

    It will represent a database table as well as the scaffold of your business object.
    `@entity` marks the class as a persistent class.
    It's required to add a primary key to your table.
    You can do so by adding the `@primaryKey` annotation to an `int` property.
    There is no restriction on where you put the file containing the entity.

    ````dart
    // entity/person.dart

    import 'package:floor/floor.dart';

    @entity
    class Person {
      @primaryKey
      final int id;

      final String name;

      Person(this.id, this.name);
    }
    ````

1. Create a **DAO (Data Access Object)**

    This component is responsible for managing access to the underlying SQLite database.
    The abstract class contains the method signatures for querying the database which have to return a `Future` or `Stream`.

    - You can define queries by adding the `@Query` annotation to a method.
        The SQL statement has to get added in parenthesis.
        The method must return a `Future` or `Stream` of the `Entity` you're querying for.

    - `@insert` marks a method as an insertion method.

    ```dart
    // dao/person_dao.dart

    import 'package:floor/floor.dart';

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

1. Create the **Database**

    It has to be an abstract class which extends `FloorDatabase`.
    Furthermore, it's required to add `@Database()` to the signature of the class.
    Make sure to add the created entity to the `entities` attribute of the `@Database` annotation.

    In order to make the generated code work, it's required to also add the listed imports.

    ```dart
    // database.dart

    // required package imports
    import 'dart:async';
    import 'package:floor/floor.dart';
    import 'package:path/path.dart';
    import 'package:sqflite/sqflite.dart' as sqflite;

    import 'dao/person_dao.dart';
    import 'model/person.dart';

    part 'database.g.dart'; // the generated code will be there

    @Database(version: 1, entities: [Person])
    abstract class AppDatabase extends FloorDatabase {
      PersonDao get personDao;
    }
    ```

1. Make sure to add `part 'database.g.dart';` beneath the imports of this file.
    It's important to note that 'database' has to get exchanged with the filename of the database definition.
    In this case, the file is named `database.dart`.

1. Run the generator with `flutter packages pub run build_runner build`.
    To automatically run it, whenever a file changes, use `flutter packages pub run build_runner watch`.

1. Use the generated code.
    For obtaining an instance of the database, use the generated `$FloorAppDatabase` class, which allows access to a database builder.
    The name is composited from `$Floor` and the database class name.
    The string passed to `databaseBuilder()` will be the database file name.
    For initializing the database, call `build()`.

    ```dart
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final person = await database.findPersonById(1);
    await database.insertPerson(person);
    ```

For further examples take a look at the [example](https://github.com/vitusortner/floor/tree/develop/example) and [floor_test](https://github.com/vitusortner/floor/tree/develop/floor_test) directories.

## Architecture
The components for storing and accessing data are **Entity**, **Data Access Object (DAO)** and **Database**.

The first, Entity, represents a persistent class and thus a database table.
DAOs manage the access to Entities and take care of the mapping between in-memory objects and table rows.
Lastly, Database, is the central access point to the underlying SQLite database.
It holds the DAOs and, beyond that, takes care of initializing the database and its schema.
[Room](https://developer.android.com/topic/libraries/architecture/room) serves as the source of inspiration for this composition, because it allows creating a clean separation of the component's responsibilities.

The figure shows the relationship between Entity, DAO and Database.

![Floor Architecture](https://raw.githubusercontent.com/vitusortner/floor/develop/img/floor-architecture.png)

## Entities
An entity is a persistent class.
Floor automatically creates the mappings between the in-memory objects and database table rows.
It's possible to supply custom metadata to Floor by adding optional values to the `Entity` annotation.
It has the additional attribute of `tableName` which opens up the possibility to use a custom name for that specific entity instead of using the class name.
`foreignKeys` allows adding foreign keys to the entity.
More information on how to use these can be found in the [Foreign Keys](#foreign-keys) section.
Indices are supported as well.
They can be used by adding an `Index` to the `indices` value of the entity.
For further information of these, please refer to the [Indices](#indices) section.

`@PrimaryKey` marks property of a class as the primary key column.
This property has to be of type int.
The value can be automatically generated by SQLite when `autoGenerate` is enabled.
For more information about primary keys and especially compound primary keys, refer to the [Primary Keys](#primary-keys) section.

`@ColumnInfo` enables custom mapping of single table columns.
With the annotation, it's possible to give columns a custom name and define if the column is able to store `null`.

**NOTE:**
Floor automatically uses the **first** constructor defined in the entity class for creating in-memory objects from database rows.  

```dart
@Entity(tableName: 'person')
class Person {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

  Person(this.id, this.name);
}
```

### Supported Types
Floor entities can hold values of the following Dart types which map to their corresponding SQLite types and vice versa.

- `int` - REAL
- `double` - REAL
- `String` - TEXT
- `bool` - REAL (0 = false, 1 = true)
- `Uint8List` - BLOB

### Primary Keys
Whenever a compound primary key is required (e.g. *n-m* relationships), the syntax for setting the keys differs from the previously mentioned way of setting primary keys.
Instead of annotating a field with `@PrimaryKey`, the `@Entity` annotation's `primaryKey` attribute is used.
It accepts a list of column names that make up the compound primary key.

```dart
@Entity(primaryKeys: ['id', 'name'])
class Person {
  final int id;

  final String name;

  Person(this.id, this.name);
}
```

### Foreign Keys
Add a list of `ForeignKey`s to the `Entity` annotation of the referencing entity.
`childColumns` define the columns of the current entity, whereas `parentColumns` define the columns of the parent entity.
Foreign key actions can get triggered after defining them for the `onUpdate` and `onDelete` properties.

```dart
@Entity(
  tableName: 'dog',
  foreignKeys: [
    ForeignKey(
      childColumns: ['owner_id'],
      parentColumns: ['id'],
      entity: Person,
    )
  ],
)
class Dog {
  @PrimaryKey()
  final int id;

  final String name;

  @ColumnInfo(name: 'owner_id')
  final int ownerId;

  Dog(this.id, this.name, this.ownerId);
}
```

### Indices
Indices help speeding up query, join and grouping operations.
For more information on SQLite indices please refer to the official [documentation](https://sqlite.org/lang_createindex.html).
To create an index with floor, add a list of indices to the `@Entity` annotation.
The example below shows how to create an index on the `custom_name` column of the entity.

The index, moreover, can be named by using its `name` attribute.
To set an index to be unique, use the `unique` attribute.
```dart
@Entity(tableName: 'person', indices: [Index(value: ['custom_name'])])
class Person {
  @primaryKey
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

  Person(this.id, this.name);
}
```

### Ignoring Fields
Getters, setters and all static fields of entities are ignored by default and thus excluded from the library's mapping.
In case further fields should be ignored, the `@ignore` annotation should be used and applied as shown in the following snippet.

```dart
class Person {
  @primaryKey
  final int id;

  final String name;

  @ignore
  String nickname;

  // ignored by default
  String get combinedName => "$name ($nickname)";

  Person(this.id, this.name);
}
```
## Database Views
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
@Database(version: 1, entities: [Person], views:[Name])
abstract class AppDatabase extends FloorDatabase {
  // DAO getters
}
```

You can then query the view via a DAO function like an entity.

**NOTE:**
Be aware that it is currently not possible to return a `Stream` object from a function which queries a database view.

## Data Access Objects
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

### Queries
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
Future<List<City>> findPersonsWithNamesLike(String name);

// usage
final name = '%foo%';
await dao.findPersonsWithNamesLike(name);
```

### Data Changes
Use the `@insert`, `@update` and `@delete` annotations for inserting and changing persistent data.
All these methods accept single or multiple entity instances.

`@insert` marks a method as an insertion method.
When using the capitalized `@Insert` you can specify a conflict strategy.
Else it just defaults to aborting the insert.
These methods can return a `Future` of either `void`, `int` or `List<int>`.
- `void` return nothing
- `int` return primary key of inserted item
- `List<int>` return primary keys of inserted items


`@update` marks a method as an update method.
When using the capitalized `@Update` you can specify a conflict strategy.
Else it just defaults to aborting the update.
These methods can return a `Future` of either `void` or `int`.
- `void` return nothing
- `int` return number of changed rows


`@delete` marks a method as a deletion method.
These methods can return a `Future` of either `void` or `int`.
- `void` return nothing
- `int` return number of deleted rows

```dart
// examples of changing multiple items with return

@insert
Future<List<int>> insertPersons(List<Person> person);

@update
Future<int> updatePersons(List<Person> person);

@delete
Future<int> deletePersons(List<Person> person);
```

### Streams
As already mentioned, queries can not only return a value once when called but also a continuous stream of query results.
The returned stream keeps you in sync with the changes happening to the database table.
This feature plays really well with the `StreamBuilder` widget.

These methods return a broadcast stream.
Thus, it can have multiple listeners.
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

**NOTE:**
It is currently not possible to return a `Stream` if the function queries a database view.
This is mostly due to the complexity of detecting which entities are involved in a database view.

### Transactions
Whenever you want to perform some operations in a transaction you have to add the `@transaction` annotation to the method.
It's also required to add the `async` modifier. These methods can only return `Future<void>`.

```dart
@transaction
Future<void> replacePersons(List<Person> persons) async {
  await deleteAllPersons();
  await insertPersons(persons);
}
```

## Migrations
Whenever you are doing changes to your entities, you're required to also migrate the old data.

First, update your entity.
Next, Increase the database version.
Define a `Migration` which specifies a `startVersion`, an `endVersion` and a function that executes SQL to migrate the data.
At last, use `addMigrations()` on the obtained database builder to add migrations.
Don't forget to trigger the code generator again, to create the code for handling the new entity.

```dart
// update entity with new 'nickname' field
@Entity(tableName: 'person')
class Person {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

  final String nickname;

  Person(this.id, this.name, this.nickname);
}

// bump up database version
@Database(version: 2)
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}

// create migration
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
});

final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
    .addMigrations([migration1to2])
    .build();
```

## In-Memory Database
To instantiate an in-memory database, use the static `inMemoryDatabaseBuilder()` method of the generated `$FloorAppDatabase` class instead of `databaseBuilder()`.

```dart
final database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
```

## Initialization Callback
In order to hook into Floor's database initialization process, `Callback` should be used.
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

final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
    .addCallback(callback)
    .build();
```

## Testing
In order to run database tests on your development machine without the need to deploy the code to an actual device, the setup has to be configured as shown in the following.
For more test references, check out the [project's tests](https://github.com/vitusortner/floor/tree/develop/floor/test/integration).

In case you're running Linux, make sure to have sqlite3 and libsqlite3-dev installed.

#### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  floor: ^0.12.0

dev_dependencies:
  floor_generator: ^0.12.0
  build_runner: ^1.7.3

  # additional dependencies
  flutter_test:
    sdk: flutter
  sqflite_ffi_test:
    git:
      url: git://github.com/tekartik/sqflite_more
      ref: dart2
      path: sqflite_ffi_test
```

#### database_test.dart
```dart
import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

// your imports follow here
import 'dao/person_dao.dart';
import 'database.dart';
import 'model/person.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();

  group('database tests', () {
    TestDatabase database;
    PersonDao personDao;

    setUp(() async {
      database = await $FloorTestDatabase
          .inMemoryDatabaseBuilder()
          .build();
      personDao = database.personDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('find person by id', () async {
      final person = Person(1, 'Simon');
      await personDao.insertPerson(person);

      final actual = await personDao.findPersonById(person.id);

      expect(actual, equals(person));
    });
  }
}
```

## Examples
For further examples take a look at the [example](https://github.com/vitusortner/floor/tree/develop/example) and [test](https://github.com/vitusortner/floor/tree/develop/floor/test/integration) directories.

## Naming
The library's name derives from the following.
*Floor* as the *bottom layer* of a [Room](https://developer.android.com/topic/libraries/architecture/room) which points to the analogy of the database layer being the bottom and foundation layer of most applications.
Where *fl* also gives a pointer that the library is used in the Flutter context.

## Bugs and Feedback
For bugs, questions and discussions please use [Github Issues](https://github.com/vitusortner/floor/issues).
For general communication use [floor's Slack](https://join.slack.com/t/floor-flutter/shared_invite/zt-d7i4yhgn-070n~ijDwXVHTpTxcVC47w).

## License
    Copyright 2019 Vitus Ortner

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
