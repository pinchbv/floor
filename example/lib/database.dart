import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@entity
class Person {
  @PrimaryKey()
  final int id;
  final String name;
  final int age;
  final bool isHungry;

  Person(this.id, this.name, this.age, this.isHungry);
}

@entity
class Car {
  @PrimaryKey(autoGenerate: false)
  final int id;
  final String manufacturer;
  final int wheels;

  Car(this.id, this.manufacturer, this.wheels);
}

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String message;

  Task(this.id, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message;

  @override
  int get hashCode => id.hashCode ^ message.hashCode;

  @override
  String toString() {
    return 'Task{id: $id, message: $message}';
  }
}

@entity
class Bar {
  final int id;
  final String foo;

  Bar(this.id, this.foo);
}

@Database()
abstract class MyDatabase extends FloorDatabase {
  static Future<MyDatabase> openDatabase() async => _$open();

  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Future<Person> findPersonById(int id);

  @Query('SELECT * FROM Car WHERE id = :id')
  Future<Car> findCarById(int id);

  @insert
  Future<void> insertPerson(Person person);

  @insert
  Future<void> insertCar(Car car);

  @Query('SELECT * FROM Task')
  Future<List<Task>> findAllTasks();

  @insert
  Future<void> insertTask(Task task);

  @update
  Future<void> updateTask(Task task);

  @update
  Future<void> updatePerson(Person person);

  @delete
  Future<void> deletePerson(Person person);
}

Future<void> main() async {
  final database = await MyDatabase.openDatabase();
}
