import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:source_gen/source_gen.dart';

class DeleteMethod {
  final MethodElement method;

  DeleteMethod(this.method);

  DartType get returnType => method.returnType;

  String get name => method.displayName;

  ParameterElement get parameter {
    final parameters = method.parameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'There is no parameter supplied for an update method. Please add one.',
        element: method,
      );
    } else if (parameters.length > 1) {
      throw InvalidGenerationSourceError(
        'Only one parameter is allowed on update methods.',
        element: method,
      );
    }
    return parameters.first;
  }

  Entity getEntity(LibraryReader library) {
    final entityClass = _getEntities(library).firstWhere(
        (entity) => entity.displayName == parameter.type.displayName);

    return Entity(entityClass);
  }

  bool insertsEntity(LibraryReader library) {
    return _getEntities(library)
        .map((clazz) => clazz.displayName)
        .any((entity) => entity == parameter.type.displayName);
  }

  List<ClassElement> _getEntities(LibraryReader library) {
    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .toList();
  }
}
