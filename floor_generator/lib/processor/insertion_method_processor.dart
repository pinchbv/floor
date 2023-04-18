import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Insert;
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_object_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/change_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';

class InsertionMethodProcessor implements Processor<InsertionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;
  final ChangeMethodProcessorError _errors;

  InsertionMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _errors = ChangeMethodProcessorError(methodElement, 'Insertion'),
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  InsertionMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final returnsList = _getReturnsList(returnType);
    final flattenedReturnType =
        _getFlattenedReturnType(returnType, returnsList);

    final returnsVoid = flattenedReturnType is VoidType;
    final returnsInt = flattenedReturnType.isDartCoreInt;
    final returnsIntList = returnsList && flattenedReturnType.isDartCoreInt;

    if (!returnsVoid && !returnsIntList && !returnsInt) {
      throw _errors.doesNotReturnVoidNorIntNorListInt;
    }

    final parameterElement = _helper.getParameterElement();
    final flattenedParameterType =
        _helper.getFlattenedParameterType(parameterElement);

    final entity = _helper.getEntity(flattenedParameterType);
    final onConflict = _getOnConflictStrategy();

    return InsertionMethod(
      _methodElement,
      name,
      returnType,
      flattenedReturnType,
      parameterElement,
      entity,
      onConflict,
    );
  }

  bool _getReturnsList(final DartType returnType) {
    final type = _methodElement.library.typeSystem.flatten(returnType);
    return type.isDartCoreList;
  }

  DartType _getFlattenedReturnType(
    final DartType returnType,
    final bool returnsList,
  ) {
    final type = _methodElement.library.typeSystem.flatten(returnType);
    return returnsList ? type.flatten() : type;
  }

  String _getOnConflictStrategy() {
    final onConflictStrategy = _methodElement
        .getAnnotation(annotations.Insert)
        ?.getField(AnnotationField.onConflict)
        ?.toEnumValueString();

    if (onConflictStrategy == null) {
      throw _errors.wrongOnConflictValue;
    } else {
      return onConflictStrategy;
    }
  }

  void _assertMethodReturnsFuture(final DartType returnType) {
    if (!returnType.isDartAsyncFuture) {
      throw _errors.doesNotReturnFuture;
    }
  }
}
