import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extensions/list_equality_extension.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/value_object/view.dart';

/// Representation of the database component.
class Database {
  final ClassElement classElement;
  final String name;
  final List<Entity> entities;
  final List<View> views;
  final List<DaoGetter> daoGetters;
  final int version;
  final List<TypeConverter> databaseTypeConverters;
  final Set<TypeConverter> allTypeConverters;

  Database(
    this.classElement,
    this.name,
    this.entities,
    this.views,
    this.daoGetters,
    this.version,
    this.databaseTypeConverters,
    this.allTypeConverters,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Database &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          entities.equals(other.entities) &&
          views.equals(other.views) &&
          daoGetters.equals(other.daoGetters) &&
          version == other.version &&
          databaseTypeConverters.equals(other.databaseTypeConverters) &&
          const SetEquality<TypeConverter>()
              .equals(allTypeConverters, other.allTypeConverters);

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      entities.hashCode ^
      views.hashCode ^
      daoGetters.hashCode ^
      version.hashCode ^
      databaseTypeConverters.hashCode ^
      allTypeConverters.hashCode;

  @override
  String toString() {
    return 'Database{classElement: $classElement, name: $name, entities: $entities, views: $views, daoGetters: $daoGetters, version: $version, typeConverters: $databaseTypeConverters, allTypeConverters: $allTypeConverters}';
  }
}
