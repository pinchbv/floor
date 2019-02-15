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

  @Query('SELECT * FROM person WHERE id = :id AND name = :name')
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

  @delete
  Future<void> deletePerson(Person person);

  @delete
  Future<void> deletePersons(List<Person> person);

  @transaction
  Future<void> replacePersons(List<Person> persons) async {
    await database.execute('DELETE FROM person');
    await insertPersons(persons);
  }
}

@Entity(tableName: 'person')
class Person {
  @PrimaryKey()
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

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
