import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Update, OnConflictStrategy;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_object_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodProcessor implements Processor<UpdateMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  UpdateMethodProcessor(
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
  UpdateMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final flattenedReturnType = _getFlattenedReturnType(returnType);
    _assertMethodReturnsNoList(flattenedReturnType);

    final returnsInt = flattenedReturnType.isDartCoreInt;
    final returnsVoid = flattenedReturnType.isVoid;

    if (!returnsInt && !returnsVoid) {
      throw InvalidGenerationSourceError(
        'Update methods have to return a Future of either void or int.',
        element: _methodElement,
      );
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

  @nonNull
  String _getOnConflictStrategy() {
    return _methodElement
        .getAnnotation(annotations.Update)
        .getField(AnnotationField.onConflict)
        .toEnumValueString(
            orElse: () => throw InvalidGenerationSourceError(
                  'Value of ${AnnotationField.onConflict} must be one of ${annotations.OnConflictStrategy.values.map((e) => e.toString()).join(',')}',
                  element: _methodElement,
                ));
  }

  @nonNull
  DartType _getFlattenedReturnType(final DartType returnType) {
    return _methodElement.library.typeSystem.flatten(returnType);
  }

  void _assertMethodReturnsNoList(final DartType flattenedReturnType) {
    if (flattenedReturnType.isDartCoreList) {
      throw InvalidGenerationSourceError(
        'Update methods have to return a Future of either void or int but not a list.',
        element: _methodElement,
      );
    }
  }

  void _assertMethodReturnsFuture(final DartType returnType) {
    if (!returnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        'Update methods have to return a Future.',
        element: _methodElement,
      );
    }
  }
}
