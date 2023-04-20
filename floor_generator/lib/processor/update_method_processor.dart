import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Update;
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_object_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/change_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/update_method.dart';

class UpdateMethodProcessor implements Processor<UpdateMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;
  final ChangeMethodProcessorError _errors;

  UpdateMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _errors = ChangeMethodProcessorError(methodElement, 'Update'),
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  UpdateMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final flattenedReturnType = _getFlattenedReturnType(returnType);
    _assertMethodReturnsNoList(flattenedReturnType);

    final returnsInt = flattenedReturnType.isDartCoreInt;
    final returnsVoid = flattenedReturnType is VoidType;

    if (!returnsInt && !returnsVoid) {
      throw _errors.doesNotReturnVoidNorInt;
    }

    final parameterElement = _helper.getParameterElement();
    final flattenedParameterType =
        _helper.getFlattenedParameterType(parameterElement);
    final entity = _helper.getEntity(flattenedParameterType);
    final onConflict = _getOnConflictStrategy();

    return UpdateMethod(
      _methodElement,
      name,
      returnType,
      flattenedReturnType,
      parameterElement,
      entity,
      onConflict,
    );
  }

  String _getOnConflictStrategy() {
    final onConflictStrategy = _methodElement
        .getAnnotation(annotations.Update)
        ?.getField(AnnotationField.onConflict)
        ?.toEnumValueString();

    if (onConflictStrategy == null) {
      throw _errors.wrongOnConflictValue;
    } else {
      return onConflictStrategy;
    }
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
