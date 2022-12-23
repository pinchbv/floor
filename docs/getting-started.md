# Getting Started

## 1. Setup Dependencies

Add the runtime dependency `floor` as well as the generator `floor_generator` to your `pubspec.yaml`.
The third dependency is `build_runner` which has to be included as a dev dependency just like the generator.

- `floor` holds all the code you are going to use in your application.
- `floor_generator` includes the code for generating the database classes.
- `build_runner` enables a concrete way of generating source code files.

```yaml
dependencies:
  flutter:
    sdk: flutter
  floor: ^1.4.0

dev_dependencies:
  floor_generator: ^1.4.0
  build_runner: ^2.1.2
```

## 2. Create an Entity

It will represent a database table as well as the scaffold of your business object.
`@entity` marks the class as a persistent class.
It's required to add a primary key to your table.
You can do so by adding the `@primaryKey` annotation to an `int` property.
There is no restriction on where you put the file containing the entity.

```dart
// entity/person.dart

import 'package:floor/floor.dart';

@entity
class Person {
  @primaryKey
  final int id;
  
  final String name;
  
  Person(this.id, this.name);
}
```

## 3. Create a DAO (Data Access Object)

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
  Stream<Person?> findPersonById(int id);
  
  @insert
  Future<void> insertPerson(Person person);
}
```

## 4. Create the Database

It has to be an abstract class which extends `FloorDatabase`.
Furthermore, it's required to add `@Database()` to the signature of the class.
Make sure to add the created entity to the `entities` attribute of the `@Database` annotation.
In order to make the generated code work, it's required to also add the listed imports.

Make sure to add `part 'database.g.dart';` beneath the imports of this file.
It's important to note that 'database' has to get exchanged with the filename of the database definition.
In this case, the file is named `database.dart`.

```dart
// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/person_dao.dart';
import 'entity/person.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}
```

## 5. Run the Code Generator

Run the generator with `flutter packages pub run build_runner build`.
To automatically run it, whenever a file changes, use `flutter packages pub run build_runner watch`.

## 6. Use the Generated Code

For obtaining an instance of the database, use the generated `$FloorAppDatabase` class, which allows access to a database builder.
The name is being composed by `$Floor` and the database class name.
The string passed to `databaseBuilder()` will be the database file name.
For initializing the database, call `build()` and make sure to `await` the result.

In order to retrieve the `PersonDao` instance, invoking the `persoDao` getter on the database instance is enough.
Its functions can be used as shown in the following snippet.

```dart
final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

final personDao = database.personDao;
final person = Person(1, 'Frank');

await personDao.insertPerson(person);
final result = await personDao.findPersonById(1);
```

For further examples take a look at the [example](https://github.com/vitusortner/floor/tree/develop/example) and [test](https://github.com/vitusortner/floor/tree/develop/floor/test/integration) directories.
