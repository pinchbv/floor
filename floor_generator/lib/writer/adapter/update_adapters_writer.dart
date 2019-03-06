import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:source_gen/source_gen.dart';

class UpdateAdaptersWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<UpdateMethod> updateMethods;
  final List<Entity> streamEntities;

  UpdateAdaptersWriter(
    this.library,
    this.builder,
    this.updateMethods,
    this.streamEntities,
  );

  void write() {
    final updateEntities = updateMethods
        .map((method) => method.getEntity(library))
        .where((entity) => entity != null)
        .toSet();

    for (final entity in updateEntities) {
      final entityName = entity.name;

      final cacheName = '_${entityName}UpdateAdapterCache';
      final type = refer('UpdateAdapter<${entity.clazz.displayName}>');

      final adapterCache = Field((builder) => builder
        ..name = cacheName
        ..type = type);

      builder..fields.add(adapterCache);

      final valueMapper =
          '(${entity.clazz.displayName} item) => ${entity.getValueMapping(library)}';

      final requiresChangeListener =
          streamEntities.any((streamEntity) => streamEntity == entity);

      final getAdapter = Method((builder) => builder
        ..type = MethodType.getter
        ..name = '_${entityName}UpdateAdapter'
        ..returns = type
        ..body = Code('''
          return $cacheName ??= UpdateAdapter(database, '$entityName', '${entity.primaryKeyColumn.name}', $valueMapper${requiresChangeListener ? ', changeListener' : ''});
        '''));

      builder..methods.add(getAdapter);
    }
  }
}
