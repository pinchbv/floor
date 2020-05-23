import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:floor_generator/value_object/entity.dart';

/// Representation of the database component.
class Database {
  final ClassElement classElement;
  final String name;
  final List<Entity> entities;
  final List<View> views;
  final List<DaoGetter> daoGetters;
  final int version;
  final bool hasViewStreams;
  final Set<Entity> streamEntities;

  Database(
    this.classElement,
    this.name,
    this.entities,
    this.views,
    this.daoGetters,
    this.version,
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
      hasViewStreams.hashCode ^
      streamEntities.hashCode;

  @override
  String toString() {
    return 'Database{classElement: $classElement, name: $name, entities: $entities, views: $views, daoGetters: $daoGetters, version: $version, hasViewStreams: $hasViewStreams, streamEntities: $streamEntities}';
  }
}
