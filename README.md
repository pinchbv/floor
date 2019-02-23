# Floor
**A supportive SQLite abstraction for your Flutter applications.**

This package is under heavy development and the API will likely change.

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
          path: /floor
    
    dev_dependencies:
      flutter_test:
        sdk: flutter
      floor_generator:
        git: 
            url: https://github.com/vitusortner/floor.git
            path: /floor_generator
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
    @Database()
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
    
For further examples take a look at the `example` and `floor_test` directories.
    

## Querying
Method signatures turn into query methods by adding the `@Query()` annotation with the query in parenthesis to them.
Be patient about your SQL statements.
The are only partly validated while generating the code.

````dart
@Query('SELECT * FROM Person WHERE id = :id')
Future<Person> findPersonById(int id);

@Query('SELECT * FROM Person WHERE id = :id AND name = :name')
Future<Person> findPersonByIdAndName(int id, String name);

@Query('SELECT * FROM Person')
Future<List<Person>> findAllPersons(); // select multiple items
````

## Persisting Data Changes
- `@insert` marks a method as an insertion method.
    It accepts a single but also multiple items as input.
    These methods can return a `Future` of either `void`, `int` or `List<int>`.
    - `void` return nothing
    - `int` return primary key of inserted item
    - `List<int>` return primary keys of inserted items
     
- `@update` marks a method as an update method.
    It accepts a single but also multiple items as input.
    These methods can return a `Future` of either `void`, `int` or `List<int>`.
    - `void` return nothing
    - `int` return number of changed rows
    - `List<int>` return number of changed rows
    
- `@delete` marks a method as a deletion method.
    It accepts a single but also multiple items as input.
    These methods can return a `Future` of either `void`, `int` or `List<int>`.
    - `void` return nothing
    - `int` return number of deleted rows
    - `List<int>` return number of deleted rows
    
```dart
// examples of changing multiple items with return 

@insert
Future<List<int>> insertPersons(List<Person> person);

@update
Future<List<int>> updatePersons(List<Person> person);

@delete
Future<List<int>> deletePersons(List<Person> person);
```
    
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
