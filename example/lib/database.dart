import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@entity
class Person {
  @primaryKey
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

@database
abstract class MyDatabase extends FloorDatabase {
  static Future<MyDatabase> openDatabase() async => await _$open();

  @Query('SELECT * FROM PERSON')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Future<Person> findPersonById(int id);

  @Query('SELECT * FROM Car WHERE id = :id')
  Future<Car> findCarById(int id);
}

Future<void> main() async {
  final database = await MyDatabase.openDatabase();
}
