import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/dao_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/dao_getter.dart';
import 'package:floor_generator/value_object/database.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

class DatabaseProcessor extends Processor<Database> {
  final ClassElement _classElement;
  final List<Entity> _entities;

  DatabaseProcessor(
    final ClassElement classElement,
    final List<Entity> entities,
  )   : assert(classElement != null),
        assert(entities != null),
        _classElement = classElement,
        _entities = entities;

  @override
  Database process() {
    final databaseName = _classElement.displayName;
    final daoGetters = _getDaoGetters(databaseName);
    final version = _getDatabaseVersion();

    return Database(
      _classElement,
      databaseName,
      _entities,
      daoGetters,
      version,
    );
  }

  int _getDatabaseVersion() {
    final version = _classElement.metadata
        .firstWhere(isDatabaseAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.DATABASE_VERSION)
        ?.toIntValue();

    if (version == null) {
      throw InvalidGenerationSourceError(
        'No version for this database specified even though it is required.',
        element: _classElement,
      );
    }
    return version;
  }

  List<DaoGetter> _getDaoGetters(final String databaseName) {
    // TODO decide for either implementing this approach (include adding
    //  entities to the database annotation) or keep it like it is now
    //  another option would be to get the libraryElement form the classElement
    //  e.g. _classElement.library;

//    final entities = _classElement.metadata
//        .firstWhere(isDatabaseAnnotation)
//        .computeConstantValue()
//        .getField(AnnotationField.DATABASE_ENTITIES)
//        ?.toListValue()
//        ?.map((object) => object.toTypeValue().element)
//        ?.whereType<ClassElement>();

    return _classElement.fields.where(_isDao).map((field) {
      final classElement = field.type.element as ClassElement;
      final name = field.displayName;

      final dao = DaoProcessor(
        classElement,
        name,
        databaseName,
        _entities,
      ).process();

      return DaoGetter(field, name, dao);
    }).toList();
  }

  bool _isDao(final FieldElement fieldElement) {
    final element = fieldElement.type.element;
    if (element is ClassElement) {
      return element.metadata.any(isDaoAnnotation) && element.isAbstract;
    } else {
      return false;
    }
  }
}
