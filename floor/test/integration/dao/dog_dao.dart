import 'dart:typed_data';

import 'package:floor/floor.dart';

import '../model/dog.dart';

@dao
abstract class DogDao {
  @insert
  Future<void> insertDog(Dog dog);

  @Query('SELECT * FROM dog WHERE owner_id = :id')
  Future<Dog> findDogForPersonId(int id);

  @Query('SELECT * FROM dog')
  Future<List<Dog>> findAllDogs();

  @update
  Future<void> updateDog(Dog dog);

  @Query('SELECT * FROM dog WHERE picture = :pic')
  Future<Dog> findDogForPicture(Uint8List pic);
}
