import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

/// Groups common functionality of change method processors.
class ChangeMethodProcessorHelper {
  final MethodElement2 _methodElement;
  final List<Entity> _entities;

  const ChangeMethodProcessorHelper(
    final MethodElement2 methodElement,
    final List<Entity> entities,
  )   : _methodElement = methodElement,
        _entities = entities;

  FormalParameterElement getParameterElement() {
    final parameters = _methodElement.formalParameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'There is no parameter supplied for this method. Please add one.',
        element: _methodElement,
      );
    } else if (parameters.length > 1) {
      throw InvalidGenerationSourceError(
        'Only one parameter is allowed on this.',
        element: _methodElement,
      );
    }
    return parameters.first;
  }

  DartType getFlattenedParameterType(
    final FormalParameterElement parameterElement,
  ) {
    final changesMultipleItems = parameterElement.type.isDartCoreList;

    return changesMultipleItems ? parameterElement.type.flatten() : parameterElement.type;
  }

  Entity getEntity(final DartType flattenedParameterType) {
    return _entities.firstWhere(
        (entity) => entity.classElement.displayName == flattenedParameterType.getDisplayString(withNullability: false),
        orElse: () => throw InvalidGenerationSourceError('You are trying to change an object which is not an entity.',
            element: _methodElement));
  }
}
