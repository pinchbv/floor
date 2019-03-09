import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/database_processor.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/writer/dao_writer.dart';
import 'package:floor_generator/writer/database_writer.dart';
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
