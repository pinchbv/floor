import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:source_gen/source_gen.dart';

class QueryAdapterWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<QueryMethod> queryMethods;
  final bool requiresChangeListener;

  QueryAdapterWriter(
    this.library,
    this.builder,
    this.queryMethods,
    this.requiresChangeListener,
  );

  void write() {
    final queryMappers = queryMethods
        .map((method) => method.getEntity(library))
        .where((entity) => entity != null)
        .toSet()
        .map((entity) {
      final constructor = entity.getConstructor(library);
      final name = '_${entity.name}Mapper';

      return Field((builder) => builder
        ..name = name
        ..modifier = FieldModifier.final$
        ..assignment = Code('(Map<String, dynamic> row) => $constructor'));
    });

    const cacheName = '_queryAdapterCache';

    final queryAdapterSingleton = Field((builder) => builder
      ..name = cacheName
      ..type = refer('QueryAdapter'));

    final getQueryAdapter = Method((builder) => builder
      ..name = '_queryAdapter'
      ..returns = refer('QueryAdapter')
      ..type = MethodType.getter
      ..lambda = true
      ..body = Code(
          "$cacheName ??= QueryAdapter(database${requiresChangeListener ? ', changeListener' : ''})"));

    builder..fields.addAll(queryMappers);
    builder..fields.add(queryAdapterSingleton);
    builder..methods.add(getQueryAdapter);
  }
}
