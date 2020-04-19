import 'package:floor/floor.dart';

import '../model/person.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM person')
  Stream<List<Person>> findAllPersonsAsStream();

  @Query('SELECT * FROM person WHERE id = :id')
  Future<Person> findPersonById(int id);

  @Query('SELECT * FROM person WHERE id = :id')
  Stream<Person> findPersonByIdAsStream(int id);

  @Query('SELECT * FROM person WHERE id = :id AND custom_name = :name')
  Future<Person> findPersonByIdAndName(int id, String name);

  @Query('SELECT * FROM person WHERE id IN (:ids)')
  Future<List<Person>> findPersonsWithIds(List<int> ids);

  @Query('SELECT * FROM person WHERE custom_name IN (:names)')
  Future<List<Person>> findPersonsWithNames(List<String> names);

  @Query('SELECT * FROM person WHERE custom_name LIKE :name')
  Future<List<Person>> findPersonsWithNamesLike(String name);

  @Insert(onConflict: OnConflictStrategy.replace)
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

  @Query('DELETE FROM person')
  Future<void> deleteAllPersons();
}
