import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

part 'model/address.dart';

part 'model/dog.dart';

part 'model/person.dart';

@Database(version: 2)
abstract class TestDatabase extends FloorDatabase {
  static Future<TestDatabase> openDatabase(List<Migration> migrations) async =>
      _$open(migrations);

  @Query('SELECT * FROM person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM person WHERE id = :id')
  Future<Person> findPersonById(int id);

  @Query('SELECT * FROM person WHERE id = :id AND custom_name = :name')
  Future<Person> findPersonByIdAndName(int id, String name);

  @Insert(onConflict: OnConflictStrategy.REPLACE)
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
