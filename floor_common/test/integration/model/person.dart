import 'package:floor_common/floor_common.dart';

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
