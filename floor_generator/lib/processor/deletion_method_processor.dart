import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/processor/error/change_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class DeletionMethodProcessor implements Processor<DeletionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;
  final ChangeMethodProcessorError _errors;

  DeletionMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _errors = ChangeMethodProcessorError(methodElement, 'Deletion'),
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  DeletionMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final flattenedReturnType = _getFlattenedReturnType(returnType);
    _assertMethodReturnsNoList(flattenedReturnType);
    final returnsVoid = flattenedReturnType is VoidType;
    final returnsInt = flattenedReturnType.isDartCoreInt;

    if (!returnsVoid && !returnsInt) {
      throw _errors.doesNotReturnVoidNorInt;
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

  DartType _getFlattenedReturnType(final DartType returnType) {
    return _methodElement.library.typeSystem.flatten(returnType);
  }

  void _assertMethodReturnsNoList(final DartType flattenedReturnType) {
    if (flattenedReturnType.isDartCoreList) {
      throw _errors.shouldNotReturnList;
    }
  }

  void _assertMethodReturnsFuture(final DartType returnType) {
    if (!returnType.isDartAsyncFuture) {
      throw _errors.doesNotReturnFuture;
    }
  }
}
