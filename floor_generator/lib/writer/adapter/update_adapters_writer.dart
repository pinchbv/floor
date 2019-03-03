import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:source_gen/source_gen.dart';

class UpdateAdaptersWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<UpdateMethod> updateMethods;

  UpdateAdaptersWriter(this.library, this.builder, this.updateMethods);

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

      final getAdapter = Method((builder) => builder
        ..type = MethodType.getter
        ..name = '_${entityName}UpdateAdapter'
        ..returns = type
        ..body = Code('''
          return $cacheName ??= UpdateAdapter(database, '$entityName', '${entity.primaryKeyColumn.name}', $valueMapper);
        '''));

      builder..methods.add(getAdapter);
    }
  }
}
