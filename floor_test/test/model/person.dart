part of '../database.dart';

@Entity(tableName: 'person')
class Person {
  @PrimaryKey()
  final int id;

  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

  @embedded
  final Address address;

  Person(this.id, this.name, this.address);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ address.hashCode;

  @override
  String toString() {
    return 'Person{id: $id, name: $name, address: $address}';
  }
}
