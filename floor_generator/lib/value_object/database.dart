import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/entity.dart';

/// Representation of the database component.
class Database {
  final ClassElement classElement;
  final String name;
  final List<Entity> entities;
  final List<DaoGetter> daoGetters;
  final int version;
  final bool overrideOpen;

  Database(
    this.classElement,
    this.name,
    this.entities,
    this.daoGetters,
    this.version,
    this.overrideOpen,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Database &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          entities == other.entities &&
          daoGetters == other.daoGetters &&
          version == other.version &&
          overrideOpen == other.overrideOpen;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      entities.hashCode ^
      daoGetters.hashCode ^
      version.hashCode;

  @override
  String toString() {
    return 'Database{classElement: $classElement, name: $name, entities: $entities, daoGetters: $daoGetters, version: $version}';
  }
}
