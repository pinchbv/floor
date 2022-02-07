import 'package:floor_common/floor_common.dart';

import 'person.dart';

@Entity(
  tableName: 'dog',
  foreignKeys: [
    ForeignKey(
      childColumns: ['owner_id'],
      parentColumns: ['id'],
      entity: Person,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class Dog {
  @primaryKey
  final int? id;

  final String name;

  @ColumnInfo(name: 'nick_name')
  final String nickName;

  @ColumnInfo(name: 'owner_id')
  final int ownerId;

  Dog(this.id, this.name, this.nickName, this.ownerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          nickName == other.nickName &&
          ownerId == other.ownerId;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ nickName.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, nickName: $nickName, ownerId: $ownerId}';
  }
}
