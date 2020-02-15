import 'dart:typed_data';

import 'package:collection/collection.dart';
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

  final String name;

  @ColumnInfo(name: 'nick_name')
  final String nickName;

  @ColumnInfo(name: 'owner_id')
  final int ownerId;

  final Uint8List picture;

  Dog(this.id, this.name, this.nickName, this.ownerId, this.picture);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          nickName == other.nickName &&
          const ListEquality<int>().equals(picture, other.picture) &&
          ownerId == other.ownerId;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ nickName.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, nickName: $nickName, ownerId: $ownerId, picture: $picture}';
  }
}
