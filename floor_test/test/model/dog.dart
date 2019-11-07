import 'package:floor/floor.dart';

import 'person.dart';

@Entity(
  tableName: 'dog',
  foreignKeys: [
    ForeignKey(
      childColumns: ['owner_id'],
      parentColumns: ['id'],
      entity: Person,
      onDelete: ForeignKeyAction.CASCADE,
    )
  ],
)
class Dog {
  @primaryKey
  final int id;

  @transient
  final String color;

  @transient
  final String alias;

  final String name;

  @ColumnInfo(name: 'nick_name')
  final String nickName;

  @ColumnInfo(name: 'owner_id')
  final int ownerId;

  Dog(this.id,this.color ,this.alias, this.name, this.nickName, this.ownerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          color == other.color &&
          alias == other.alias &&
          name == other.name &&
          nickName == other.nickName &&
          ownerId == other.ownerId;

  @override
  int get hashCode =>
      id.hashCode ^ color.hashCode ^ alias.hashCode ^ name.hashCode ^ nickName.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'Dog{id: $id, color: $color, alias: $alias, name: $name, nickName: $nickName, ownerId: $ownerId}';
  }
}
