import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Database, dao, Entity;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/error/database_processor_error.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';

class DatabaseProcessor extends Processor<Database> {
  final DatabaseProcessorError _processorError;

  final ClassElement _classElement;

  DatabaseProcessor(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement,
        _processorError = DatabaseProcessorError(classElement);

  @nonNull
  @override
  Database process() {
    final databaseName = _classElement.displayName;
    final entities = _getEntities(_classElement);
    final daoGetters = _getDaoGetters(databaseName, entities);
    final version = _getDatabaseVersion();

    return Database(_classElement, databaseName, entities, daoGetters, version);
  }

  @nonNull
  int _getDatabaseVersion() {
    final version = typeChecker(annotations.Database)
        .firstAnnotationOfExact(_classElement)
        .getField(AnnotationField.DATABASE_VERSION)
        ?.toIntValue();

    if (version == null) throw _processorError.VERSION_IS_MISSING;
    if (version < 1) throw _processorError.VERSION_IS_BELOW_ONE;

    return version;
  }

  @nonNull
  List<DaoGetter> _getDaoGetters(
    final String databaseName,
    final List<Entity> entities,
  ) {
    return _classElement.fields.where(_isDao).map((field) {
      final classElement = field.type.element as ClassElement;
      final name = field.displayName;

      final dao = DaoProcessor(
        classElement,
        name,
        databaseName,
        entities,
      ).process();

      return DaoGetter(field, name, dao);
    }).toList();
  }

  @nonNull
  bool _isDao(final FieldElement fieldElement) {
    final element = fieldElement.type.element;
    return element is ClassElement ? _isDaoClass(element) : false;
  }

  @nonNull
  bool _isDaoClass(final ClassElement classElement) {
    return typeChecker(annotations.dao.runtimeType)
            .hasAnnotationOfExact(classElement) &&
        classElement.isAbstract;
  }

  @nonNull
  List<Entity> _getEntities(final ClassElement databaseClassElement) {
    final entities = typeChecker(annotations.Database)
        .firstAnnotationOfExact(_classElement)
        .getField(AnnotationField.DATABASE_ENTITIES)
        ?.toListValue()
        ?.map((object) => object.toTypeValue().element)
        ?.whereType<ClassElement>()
        ?.where(_isEntity)
        ?.map((classElement) => EntityProcessor(classElement).process())
        ?.toList();

    if (entities == null || entities.isEmpty) {
      throw _processorError.NO_ENTITIES_DEFINED;
    }

    return entities;
  }

  @nonNull
  bool _isEntity(final ClassElement classElement) {
    return !classElement.isAbstract &&
        typeChecker(annotations.Entity).hasAnnotationOfExact(classElement);
  }
}
