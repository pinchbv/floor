import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';

class InsertionMethodProcessor implements Processor<InsertionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  InsertionMethodProcessor(
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
  InsertionMethod process() {
    final name = _methodElement.name;
    final returnType = _methodElement.returnType;

    _assertMethodReturnsFuture(returnType);

    final returnsList = _getReturnsList(returnType);
    final flattenedReturnType =
        _getFlattenedReturnType(returnType, returnsList);

    final returnsVoid = flattenedReturnType.isVoid;
    final returnsInt = isInt(flattenedReturnType);
    final returnsIntList = returnsList && isInt(flattenedReturnType);

    if (!returnsVoid && !returnsIntList && !returnsInt) {
      throw InvalidGenerationSourceError(
        'Insertion methods have to return a Future of either void, int or List<int>.',
        element: _methodElement,
      );
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

  @nonNull
  bool _getReturnsList(final DartType returnType) {
    final type = returnType.flattenFutures(_methodElement.context.typeSystem);
    return isList(type);
  }

  @nonNull
  DartType _getFlattenedReturnType(
    final DartType returnType,
    final bool returnsList,
  ) {
    final type = returnType.flattenFutures(_methodElement.context.typeSystem);
    return returnsList ? flattenList(type) : type;
  }

  @nonNull
  String _getOnConflictStrategy() {
    final strategy = _methodElement.metadata
        .firstWhere(isInsertAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.ON_CONFLICT)
        .toIntValue();

    return 'sqflite.ConflictAlgorithm.${OnConflictStrategy.getConflictAlgorithm(strategy)}';
  }

  void _assertMethodReturnsFuture(final DartType returnType) {
    if (!returnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        'Insertion methods have to return a Future.',
        element: _methodElement,
      );
    }
  }
}
