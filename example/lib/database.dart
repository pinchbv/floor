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

  Person(this.id, this.name, this.age);
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
abstract class MyDatabase extends FloorDatabase {}
