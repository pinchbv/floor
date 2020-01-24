import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

class DeletionMethodProcessor implements Processor<DeletionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  DeletionMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper changeMethodProcessorHelper,
  ])  : assert(methodElement != null),
        assert(entities != null),
        _methodElement = methodElement,
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @nonNull
  @override
  DeletionMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final flattenedReturnType = _getFlattenedReturnType(returnType);
    _assertMethodReturnsNoList(flattenedReturnType);

    final returnsVoid = flattenedReturnType.isVoid;
    final returnsInt = flattenedReturnType.isDartCoreInt;

    if (!returnsVoid && !returnsInt) {
      throw InvalidGenerationSourceError(
        'Deletion methods have to return a Future of either void or int.',
        element: _methodElement,
      );
    }

    final parameterElement = _helper.getParameterElement();
    final flattenedParameterType =
        _helper.getFlattenedParameterType(parameterElement);

    final entity = _helper.getEntity(flattenedParameterType);

    return DeletionMethod(
      _methodElement,
      name,
      returnType,
      flattenedReturnType,
      parameterElement,
      entity,
    );
  }

  @nonNull
  DartType _getFlattenedReturnType(final DartType returnType) {
    return _methodElement.library.typeSystem.flatten(returnType);
  }

  void _assertMethodReturnsNoList(final DartType flattenedReturnType) {
    if (flattenedReturnType.isDartCoreList) {
      throw InvalidGenerationSourceError(
        'Deletion methods have to return a Future of either void or int but not a list.',
        element: _methodElement,
      );
    }
  }

  void _assertMethodReturnsFuture(final DartType returnType) {
    if (!returnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        'Deletion methods have to return a Future.',
        element: _methodElement,
      );
    }
  }
}
