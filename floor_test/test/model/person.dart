import 'package:floor/floor.dart';

@Entity(
  tableName: 'person',
  indices: [
    Index(value: ['custom_name'])
  ],
)
class Person {
  @primaryKey
  final int id;

  @transient
  final String nickName;

  @transient
  final String alias;


  @ColumnInfo(name: 'custom_name', nullable: false)
  final String name;

  Person(this.id,this.nickName,this.alias, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nickName == other.nickName &&
          alias == other.alias &&
          name == other.name ;

  @override
  int get hashCode => id.hashCode ^ nickName.hashCode ^ alias.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Person{id: $id, nickName: $nickName, alias: $alias, name: $name}';
  }
}
