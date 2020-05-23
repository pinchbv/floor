import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/list_equality_extension.dart';
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
  final bool hasViewStreams;
  final Set<Entity> streamEntities;

  Database(
    this.classElement,
    this.name,
    this.entities,
    this.views,
    this.daoGetters,
    this.version,
    this.databaseTypeConverters,
    this.allTypeConverters,
  )   : streamEntities =
            daoGetters.expand((dg) => dg.dao.streamEntities).toSet(),
        hasViewStreams = daoGetters.any((dg) => dg.dao.streamViews.isNotEmpty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Database &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          const ListEquality<Entity>().equals(entities, other.entities) &&
          const ListEquality<View>().equals(views, other.views) &&
          const ListEquality<DaoGetter>()
              .equals(daoGetters, other.daoGetters) &&
          version == other.version &&
          databaseTypeConverters.equals(other.databaseTypeConverters) &&
          const SetEquality<TypeConverter>()
              .equals(allTypeConverters, other.allTypeConverters) &&
          hasViewStreams == hasViewStreams &&
          const SetEquality<Entity>()
              .equals(streamEntities, other.streamEntities);

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      entities.hashCode ^
      views.hashCode ^
      daoGetters.hashCode ^
      version.hashCode ^
      databaseTypeConverters.hashCode ^
      allTypeConverters.hashCode ^
      hasViewStreams.hashCode ^
      streamEntities.hashCode;

  @override
  String toString() {
    // TODO #165
    return 'Database{classElement: $classElement, name: $name, entities: $entities, views: $views, daoGetters: $daoGetters, version: $version, hasViewStreams: $hasViewStreams, streamEntities: $streamEntities}';
  }
}
