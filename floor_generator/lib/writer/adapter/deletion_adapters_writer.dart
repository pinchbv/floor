import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/delete_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

class DeletionAdaptersWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<DeleteMethod> deleteMethods;
  final List<Entity> streamEntities;

  DeletionAdaptersWriter(
    this.library,
    this.builder,
    this.deleteMethods,
    this.streamEntities,
  );

  void write() {
    final deleteEntities = deleteMethods
        .map((method) => method.getEntity(library))
        .where((entity) => entity != null)
        .toSet();

    for (final entity in deleteEntities) {
      final entityName = entity.name;

      final cacheName = '_${entityName}DeletionAdapterCache';
      final type = refer('DeletionAdapter<${entity.clazz.displayName}>');

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
        ..name = '_${entityName}DeletionAdapter'
        ..returns = type
        ..body = Code('''
          return $cacheName ??= DeletionAdapter(database, '$entityName', '${entity.primaryKeyColumn.name}', $valueMapper${requiresChangeListener ? ', changeListener' : ''});
        '''));

      builder..methods.add(getAdapter);
    }
  }
}
