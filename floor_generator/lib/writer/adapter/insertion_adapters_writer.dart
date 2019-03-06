import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insert_method.dart';
import 'package:source_gen/source_gen.dart';

class InsertionAdaptersWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<InsertMethod> insertMethods;
  final List<Entity> streamEntities;

  InsertionAdaptersWriter(
    this.library,
    this.builder,
    this.insertMethods,
    this.streamEntities,
  );

  void write() {
    final insertEntities = insertMethods
        .map((method) => method.getEntity(library))
        .where((entity) => entity != null)
        .toSet();

    for (final entity in insertEntities) {
      final entityName = entity.name;

      final cacheName = '_${entityName}InsertionAdapterCache';
      final type = refer('InsertionAdapter<${entity.clazz.displayName}>');

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
        ..name = '_${entityName}InsertionAdapter'
        ..returns = type
        ..body = Code('''
          return $cacheName ??= InsertionAdapter(database, '$entityName', $valueMapper${requiresChangeListener ? ', changeListener' : ''});
        '''));

      builder..methods.add(getAdapter);
    }
  }
}
