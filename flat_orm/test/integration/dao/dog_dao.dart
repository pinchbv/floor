import 'package:flat_orm/flat_orm.dart';

import '../model/dog.dart';

@dao
abstract class DogDao {
  @insert
  Future<void> insertDog(Dog dog);

  @Query('SELECT * FROM dog WHERE owner_id = :id')
  Future<Dog?> findDogForPersonId(int id);

  @Query('SELECT * FROM dog')
  Future<List<Dog>> findAllDogs();
}
