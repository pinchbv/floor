import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
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
      final databaseClassElement = databaseClasses.first;
      final entities = _getEntities(databaseClassElement);

      if (entities == null || entities.isEmpty) {
        throw InvalidGenerationSourceError(
            'There are no entities added to the database annotation.',
            element: databaseClassElement);
      }

      return DatabaseProcessor(
        databaseClassElement,
        entities,
      ).process();
    }
  }

  List<Entity> _getEntities(final ClassElement databaseClassElement) {
    return databaseClassElement.metadata
        .firstWhere(isDatabaseAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.DATABASE_ENTITIES)
        ?.toListValue()
        ?.map((object) => object.toTypeValue().element)
        ?.whereType<ClassElement>()
        ?.where((classElement) =>
            !classElement.isAbstract &&
            classElement.metadata.any(isEntityAnnotation))
        ?.map((classElement) => EntityProcessor(classElement).process())
        ?.toList();
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
