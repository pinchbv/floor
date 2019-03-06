import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/dao.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:source_gen/source_gen.dart';

class Database {
  final ClassElement clazz;

  Database(final this.clazz);

  String _nameCache;

  String get name => _nameCache ??= clazz.displayName;

  int _versionCache;

  int get version {
    if (_versionCache != null) return _versionCache;

    final databaseVersion = clazz.metadata
        .firstWhere(isDatabaseAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.DATABASE_VERSION)
        ?.toIntValue();

    return _versionCache ??= databaseVersion != null
        ? databaseVersion
        : throw InvalidGenerationSourceError(
            'No version for this database specified even though it is required.',
            element: clazz,
          );
  }

  List<MethodElement> _methodsCache;

  List<MethodElement> get methods => _methodsCache ??= clazz.methods;

  List<Entity> getEntities(final LibraryReader library) {
    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map((entity) => Entity(entity))
        .toList();
  }

  List<QueryMethod> _queryMethodsCache;

  List<QueryMethod> get _queryMethods {
    return _queryMethodsCache ??= methods
        .where((method) => method.metadata.any(isQueryAnnotation))
        .map((method) => QueryMethod(method))
        .toList();
  }

  List<Entity> _streamEntities;

  List<Entity> getStreamEntities(final LibraryReader library) {
    return _streamEntities ??= _queryMethods
        .where((method) => method.returnsStream)
        .map((method) => method.getEntity(library))
        .toList();
  }

  List<Dao> _daosCache;

  List<Dao> getDaos(final LibraryReader library) {
    return _daosCache ??= library.classes
        .where(_isDaoClass)
        .where(_isDefinedInDatabase)
        .map((daoClass) => Dao(daoClass, _getDaoFieldName(daoClass), name))
        .toList();
  }

  String _getDaoFieldName(final ClassElement daoClass) {
    return clazz.fields
        .firstWhere((field) => field.type.displayName == daoClass.displayName)
        .displayName;
  }

  bool _isDaoClass(final ClassElement clazz) {
    return clazz.metadata.any(isDaoAnnotation) && clazz.isAbstract;
  }

  List<String> _fieldTypeNamesCache;

  List<String> get _fieldTypeNames {
    return _fieldTypeNamesCache ??=
        clazz.fields.map((field) => field.type.displayName).toList();
  }

  bool _isDefinedInDatabase(final ClassElement daoClass) {
    return _fieldTypeNames
        .any((fieldType) => daoClass.displayName == fieldType);
  }
}
