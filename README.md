# Floor
**A supportive SQLite abstraction for your Flutter applications.**

The Floor library provides a lightweight SQLite abstraction with automatic mapping between in-memory objects and database rows while still offering full control of the database with the use of SQL.

It's important to note that this library is not a full featured ORM like Hibernate and will never be.
Thus not supporting automatic relationship mapping is intentional.

This package is still in an early phase and the API will likely change.

[![Build Status](https://travis-ci.org/vitusortner/floor.svg?branch=develop)](https://travis-ci.org/vitusortner/floor)

### Table of contents

1. [How to use this library](#how-to-use-this-library)
1. [Querying](#querying)
1. [Persisting Data Changes](#persisting-data-changes)
1. [Streams](#streams)
1. [Transactions](#transactions)
1. [Entities](#entities)
1. [Foreign Keys](#foreign-keys)
1. [Migrations](#migrations)
1. [Examples](#examples)
1. [Naming](#naming)
1. [Bugs and Feedback](#bugs-and-feedback)
1. [License](#license)

## How to use this library
1. Add the runtime dependency `floor` as well as the generator `floor_generator` to your `pubspec.yaml`.
    The third dependency is `build_runner` which has to be included as a dev dependency just like the generator.

    - `floor` holds all the code you are going to use in your application.
    
    - `floor_generator` includes the code for generating the database classes.
    
    - `build_runner` enables a concrete way of generating source code files.
 
    ````yaml
    dependencies:
      flutter:
        sdk: flutter
      floor:
        git: 
          url: https://github.com/vitusortner/floor.git
          path: /floor/
    
    dev_dependencies:
      flutter_test:
        sdk: flutter
      floor_generator:
        git: 
            url: https://github.com/vitusortner/floor.git
            path: /floor_generator/
      build_runner: ^1.1.3
    ````

1. Make sure to import the following libraries.
    
    ```dart
    import 'package:floor/floor.dart';
    import 'package:path/path.dart';
    import 'package:sqflite/sqflite.dart' as sqflite;
    ```

1. Create an `Entity`.
    It will represent a database table as well as the scaffold of your business object.
    `@Entity()` marks the class as a persistent class.
    It's required to add a primary key to your table.
    You can do so by adding the `@PrimarKey()` annotation to an `int` property.

    ````dart
    @Entity()
    class Person {
      @PrimaryKey()
      final int id;
    
      final String name;
    
      Person(this.id, this.name);
    }
    ````
    
1. Create the `Database`.
    This component is responsible for managing the access to the underlying SQLite database.
    It has to be an abstract class which extends `FloorDatabase`.
    Furthermore, it's required to add `@Database()` to the signature of the class.

    This class contains the method signatures for querying the database which have to return a `Future`.
    It, moreover, holds functionality for opening the database.
    `_$open()` is a function that will get implemented by running the code generator.
    The warning, of it not being implemented, will go away then.
     
    - You can define queries by adding the `@Query` annotation to a method.
        The SQL statement has to get added in parenthesis.
        The method must return a `Future` of the `Entity` you're querying for.
        
    - `@insert` marks a method as an insertion method.
        
    ```dart
    @Database(version: 1)
    abstract class AppDatabase extends FloorDatabase {
      static Future<AppDatabase> openDatabase() async => _$open();
      
      @Query('SELECT * FROM Person')
      Future<List<Person>> findAllPersons();
      
      @Query('SELECT * FROM Person WHERE id = :id')
      Future<Person> findPersonById(int id);
      
      @insert
      Future<void> insertPerson(Person person);
    }
    ```

1. Add `part 'database.g.dart';` beneath the imports of this file.
    It's important to note, that 'database' has to get exchanged with the name of the file the entity and database is defined in.
    In this case the file is named `database.dart`.

1. Run the generator with `flutter packages pub run build_runner build`.
    To automatically run it, whenever a file changes, use `flutter packages pub run build_runner watch`.
    
1. Use the generated code.

    ```dart
    final database = await AppDatabase.openDatabase();

    final person = await database.findPersonById(1);
    await database.insertPerson(person);
    ```
    
For further examples take a look at the [example](https://github.com/vitusortner/floor/tree/develop/example) and [floor_test](https://github.com/vitusortner/floor/tree/develop/floor_test) directories.

## Querying
Method signatures turn into query methods by adding the `@Query()` annotation with the query in parenthesis to them.
Be patient about the correctness of your SQL statements.
They are only partly validated while generating the code.
These queries have to return either a `Future` or a `Stream` of an entity or `void`.
Returning `Future<void>` comes in handy whenever you want to delete the full content of a table.

````dart
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
````

## Persisting Data Changes
Use the `@insert`, `@update` and `@delete` annotations for inserting and changing persistent data.
All these methods accept single or multiple entity instances.

- **Insert**

    `@insert` marks a method as an insertion method.
    WHen using the capitalized `@Insert` you can specify a conflict strategy.
    Else it just defaults to aborting the insert.
    These methods can return a `Future` of either `void`, `int` or `List<int>`.
    - `void` return nothing
    - `int` return primary key of inserted item
    - `List<int>` return primary keys of inserted items
     
- **Update**

    `@update` marks a method as an update method.
    When using the capitalized `@Update` you can specify a conflict strategy.
    Else it just defaults to aborting the update.
    These methods can return a `Future` of either `void` or `int`.
    - `void` return nothing
    - `int` return number of changed rows
    
- **Delete** 

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

## Streams
As already mentioned, queries can not only return a value once when called, but also a continuous stream of query results.
The returned stream keeps you in sync with the changes happening to the database table.
This feature plays really well with the `StreamBuilder` widget.
```dart
// definition
@Query('SELECT * FROM Person')
Stream<List<Person>> findAllPersonsAsStream();

// usage
StreamBuilder<List<Person>>(
  stream: database.findAllPersonsAsStream(),
  builder: (BuildContext context, AsyncSnapshot<List<Person>> snapshot) {
    // do something with the values here
  },
);
```

## Transactions
Whenever you want to perform some operations in a transaction you have to add the `@transaction` annotation to the method.
It's also required to add the `async` modifier. These methods can only return `Future<void>`.

```dart
@transaction
Future<void> replacePersons(List<Person> persons) async {
  await deleteAllPersons();
  await insertPersons(persons);
}
```

## Entities
An entity is a persistent class.
Floor automatically creates the mappings between the in-memory objects and database table rows.
It's possible to supply custom metadata to Floor by adding optional values to the `Entity` annotation.
It has the additional attribute of `tableName` which opens up the possibility to use a custom name for that specific entity instead of using the class name.
Another attribute `foreignKeys` allows to add foreign keys to the entity.
More information on how to use these can be found in the [Foreign Keys](#foreign-keys) section.

`@PrimaryKey` marks a property of a class as the primary key column.
This property has to be of type int.
The value can be automatically generated by SQLite when `autoGenerate` is enabled.

`@ColumnInfo` enables custom mapping of single table columns.
With the annotation it's possible to give columns a custom name and define if the column is able to store `null`.

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

## Foreign Keys
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

## Migrations
Whenever are doing changes to your entities, you're required to also migrate the old data.

First, update your entity.
Increase the database version and change the `openDatabase` method to take in a list of `Migration`s.
This parameter has to get passed to the `_$open()` method.
Define a `Migration` which specifies a `startVersion`, an `endVersion` and a function that executes SQL to migrate the data.
Lastly, call `openDatabase` with your newly created `Migration`.
Don't forget to trigger the code generator again, to create the code for handling the new entity.

```dart
// Update entity with new 'nickname' field
@Entity(tableName: 'person')
class Person {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;
  
  final String nickname;

  Person(this.id, this.name, this.nickname);
}

// Bump up database version
@Database(version: 2)
abstract class AppDatabase extends FloorDatabase {
  static Future<AppDatabase> openDatabase(List<Migration> migrations) async =>
      _$open(migrations);
}

// Create migration
final migration1to2 = Migration(1, 2, (database) {
  database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
});

final database = await AppDatabase.openDatabase([migration1to2]);
```

## Examples
For further examples take a look at the [example](https://github.com/vitusortner/floor/tree/develop/example) and [floor_test](https://github.com/vitusortner/floor/tree/develop/floor_test) directories.
     
## Naming
*Floor - the bottom layer of a [Room](https://developer.android.com/topic/libraries/architecture/room).*

## Bugs and Feedback
For bugs, questions and discussions please use the [Github Issues](https://github.com/vitusortner/floor/issues).

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
