import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/database_processor.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:floor_generator/writer/database_builder_writer.dart';
import 'package:floor_generator/writer/database_writer.dart';
import 'package:floor_generator/writer/floor_writer.dart';
import 'package:source_gen/source_gen.dart';

/// Floor generator that produces the implementation of the persistence code.
class FloorGenerator extends GeneratorForAnnotation<annotations.Database> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    final Element element,
    final ConstantReader annotation,
    final BuildStep buildStep,
  ) {
    final database = _getDatabase(element);
    if (database == null) return null;
    final daoGetters = database.daoGetters;

    final databaseClass = DatabaseWriter(database).write();
    final daoClasses = daoGetters.map((daoGetter) => DaoWriter(
            daoGetter.dao, database.entityStreams, database.hasViewStreams)
        .write());

    final library = Library((builder) => builder
      ..body.add(FloorWriter(database.name).write())
      ..body.add(DatabaseBuilderWriter(database.name).write())
      ..body.add(databaseClass)
      ..body.addAll(daoClasses));

    return library.accept(DartEmitter()).toString();
  }

  @nonNull
  Database _getDatabase(final Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'The element annotated with @Database is not a class.',
          element: element);
    }

    final classElement = element as ClassElement;
    if (!classElement.isAbstract) {
      throw InvalidGenerationSourceError(
          'The database class has to be abstract.',
          element: classElement);
    }

    return DatabaseProcessor(classElement).process();
  }
}
