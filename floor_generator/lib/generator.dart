import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/database_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:source_gen/source_gen.dart';

/// Floor generator that produces the implementation of the persistence code.
class FloorGenerator implements Generator {
  @nullable
  @override
  FutureOr<String> generate(
    final LibraryReader library,
    final BuildStep buildStep,
  ) {
    final database = _getDatabase(library);
    if (database == null) return null;
    final daoGetters = database.daoGetters;

    final openDatabaseMethodSpec = _generateOpenDatabaseFunction(database.name);
    final databaseSpec = DatabaseWriter(database).write();
    final daoSpecs =
        daoGetters.map((daoGetter) => DaoWriter(daoGetter.dao).write());

    final librarySpec = Library((builder) => builder
      ..body.add(openDatabaseMethodSpec)
      ..body.add(databaseSpec)
      ..body.addAll(daoSpecs));

    return librarySpec.accept(DartEmitter()).toString();
  }

  @nullable
  Database _getDatabase(final LibraryReader library) {
    final databaseClasses = library.classes
        .where((clazz) =>
            clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation))
        .toList();

    if (databaseClasses.isEmpty) {
      return null;
    } else if (databaseClasses.length > 1) {
      throw InvalidGenerationSourceError(
          'There can only be one database definition per file.'
          ' There are too many classes annotated with @Database.',
          element: databaseClasses[2]);
    } else {
      return DatabaseProcessor(
        databaseClasses.first,
        _getEntities(library),
      ).process();
    }
  }

  @nonNull
  List<Entity> _getEntities(final LibraryReader library) {
    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map((entity) => EntityProcessor(entity).process())
        .toList();
  }

  @nonNull
  Method _generateOpenDatabaseFunction(final String databaseName) {
    final migrationsParameter = Parameter((builder) => builder
      ..name = 'migrations'
      ..type = refer('List<Migration>')
      ..defaultTo = const Code('const []'));

    return Method((builder) => builder
      ..returns = refer('Future<$databaseName>')
      ..name = '_\$open'
      ..modifier = MethodModifier.async
      ..optionalParameters.add(migrationsParameter)
      ..body = Code('''
            final database = _\$$databaseName();
            database.database = await database.open(migrations);
            return database;
            '''));
  }
}
