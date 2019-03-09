import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/entity_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

class DatabaseProcessor extends Processor<Database> {
  final ClassElement _classElement;

  DatabaseProcessor(
    final ClassElement classElement,
  )   : assert(classElement != null),
        _classElement = classElement;

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
    return typeChecker(annotations.Database)
            .firstAnnotationOfExact(_classElement)
            .getField(AnnotationField.DATABASE_VERSION)
            ?.toIntValue() ??
        (throw InvalidGenerationSourceError(
          'No version for this database specified even though it is required.',
          todo:
              'Add version to annotation. e.g. @Database(version:1, entities: [Person, Dog])',
          element: _classElement,
        ));
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
    return typeChecker(annotations.Database)
            .firstAnnotationOfExact(_classElement)
            .getField(AnnotationField.DATABASE_ENTITIES)
            ?.toListValue()
            ?.map((object) => object.toTypeValue().element)
            ?.whereType<ClassElement>()
            ?.where(_isEntity)
            ?.map((classElement) => EntityProcessor(classElement).process())
            ?.toList() ??
        (throw InvalidGenerationSourceError(
            'There are no entities added to the database annotation.',
            todo:
                'Add entities the annotation. e.g. @Database(version:1, entities: [Person, Dog])',
            element: _classElement));
  }

  @nonNull
  bool _isEntity(final ClassElement classElement) {
    return !classElement.isAbstract &&
        typeChecker(annotations.Entity).hasAnnotationOfExact(classElement);
  }
}
