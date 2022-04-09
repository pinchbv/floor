import 'package:flat_orm/flat_orm.dart';

import 'address.dart';

@Entity(
  tableName: 'person',
  indices: [
    Index(value: ['custom_name'])
  ],
)
class Person {
  @primaryKey
  final int? id;

  @ColumnInfo(name: 'custom_name')
  final String name;

  @embedded
  final Address? address;

  Person(this.id, this.name, [this.address]);

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
