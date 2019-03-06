import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

/// Base class for change methods (insert, update, delete).
class ChangeMethod {
  final MethodElement method;

  ChangeMethod(final this.method);

  DartType get returnType => method.returnType;

  /// Whether this method returns an int or a list of ints.
  bool get returnsInt => isInt(_flattenedReturnType);

  /// Whether this methods 'returns' void.
  bool get returnsVoid => _flattenedReturnType.isVoid;

  String get name => method.displayName;

  ParameterElement get parameter {
    final parameters = method.parameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'There is no parameter supplied for this method. Please add one.',
        element: method,
      );
    } else if (parameters.length > 1) {
      throw InvalidGenerationSourceError(
        'Only one parameter is allowed on this.',
        element: method,
      );
    }
    return parameters.first;
  }

  /// Whether this method takes a list as parameter and thus
  /// changes multiple items.
  bool get changesMultipleItems => isList(parameter.type);

  ClassElement get flattenedParameterClass {
    return _flattenedParameterType.element as ClassElement;
  }

  Entity getEntity(final LibraryReader library) {
    final entityClass = _getEntities(library).firstWhere(
        (entity) => entity.displayName == _flattenedParameterType.displayName);

    return Entity(entityClass);
  }

  bool changesEntity(final LibraryReader library) {
    return _getEntities(library)
        .map((clazz) => clazz.displayName)
        .any((entity) => entity == _flattenedParameterType.displayName);
  }

  bool get requiresAsyncModifier => returnsVoid;

  bool get returnsList {
    final type = method.returnType.flattenFutures(method.context.typeSystem);
    return isList(type);
  }

  DartType get _flattenedParameterType {
    return changesMultipleItems ? flattenList(parameter.type) : parameter.type;
  }

  List<ClassElement> _getEntities(final LibraryReader library) {
    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .toList();
  }

  DartType get _flattenedReturnType {
    final type = method.returnType.flattenFutures(method.context.typeSystem);
    return returnsList ? flattenList(type) : type;
  }
}
