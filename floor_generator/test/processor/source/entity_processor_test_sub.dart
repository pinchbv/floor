import 'package:floor_annotation/floor_annotation.dart' as annotations;

@annotations.entity
class Person {
  @annotations.primaryKey
  final int id;

  final String name;

  @annotations.sub
  final List<PersonSub> sub;

  Person(this.id, this.name, this.sub);
}

@annotations.Entity(
  foreignKeys: [
    annotations.ForeignKey(
      childColumns: ['personId'],
      parentColumns: ['id'],
      entity: Person,
    ),
  ],
)
class PersonSub {
  @annotations.primaryKey
  final int id;

  final int personId;

  PersonSub(this.id, this.personId);
}
