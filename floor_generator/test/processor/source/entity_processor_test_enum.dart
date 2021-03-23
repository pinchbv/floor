import 'package:floor_annotation/floor_annotation.dart';

@entity
class Person {
  @primaryKey
  final int id;

  final String name;

  final EnumWithValue enumWithValue;

  Person(this.id, this.name, this.enumWithValue);
}

enum EnumWithValue {
  @EnumValue(1)
  valueOne,

  @EnumValue(2)
  valueTwo,
}
