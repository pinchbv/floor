import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database()
abstract class TestDatabase extends FloorDatabase {
  static Future<TestDatabase> openDatabase() async => _$open();

  @Query('SELECT * FROM person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM person WHERE id = :id')
  Future<Person> findPersonById(int id);

  @Query('SELECT * FROM person WHERE id = :id AND custom_name = :name')
  Future<Person> findPersonByIdAndName(int id, String name);

  @insert
  Future<void> insertPerson(Person person);

  @insert
  Future<void> insertPersons(List<Person> persons);

  @insert
  Future<int> insertPersonWithReturn(Person person);

  @insert
  Future<List<int>> insertPersonsWithReturn(List<Person> persons);

  @update
  Future<void> updatePerson(Person person);

  @update
  Future<void> updatePersons(List<Person> persons);

  @update
  Future<int> updatePersonWithReturn(Person person);

  @update
  Future<int> updatePersonsWithReturn(List<Person> persons);

  @delete
  Future<void> deletePerson(Person person);

  @delete
  Future<void> deletePersons(List<Person> person);

  @delete
  Future<int> deletePersonWithReturn(Person person);

  @delete
  Future<int> deletePersonsWithReturn(List<Person> persons);

  @transaction
  Future<void> replacePersons(List<Person> persons) async {
    await deleteAllPersons();
    await insertPersons(persons);
  }

  @insert
  Future<void> insertDog(Dog dog);

  @Query('SELECT * FROM dog WHERE owner_id = :id')
  Future<Dog> findDogForPersonId(int id);

  @Query('SELECT * FROM dog')
  Future<List<Dog>> findAllDogs();

  @Query('DELETE FROM person')
  Future<void> deleteAllPersons();
}

@Entity(tableName: 'person')
class Person {
  @PrimaryKey()
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

//  @embedded
//  final Address address;

  Person(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Person{id: $id, name: $name}';
  }
}

@Entity(
  tableName: 'dog',
  foreignKeys: [
    ForeignKey(
      childColumns: ['owner_id'],
      parentColumns: ['id'],
      entity: Person,
      onDelete: ForeignKeyAction.CASCADE,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ownerId == other.ownerId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, ownerId: $ownerId}';
  }
}

class Address {
  final String street;
  final String city;

  Address(this.street, this.city);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          street == other.street &&
          city == other.city;

  @override
  int get hashCode => street.hashCode ^ city.hashCode;

  @override
  String toString() {
    return 'Address{street: $street, city: $city}';
  }
}
