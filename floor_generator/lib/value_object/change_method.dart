import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/entity.dart';

/// Base class for change methods (insert, update, delete).
class ChangeMethod {
  final MethodElement methodElement;
  final String name;
  final DartType returnType;
  final DartType flattenedReturnType;
  final ParameterElement parameterElement;
  final Entity entity;

  ChangeMethod(
    this.methodElement,
    this.name,
    this.returnType,
    this.flattenedReturnType,
    this.parameterElement,
    this.entity,
  );

  bool get requiresAsyncModifier => flattenedReturnType is VoidType;

  bool get changesMultipleItems => parameterElement.type.isDartCoreList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeMethod &&
          runtimeType == other.runtimeType &&
          methodElement == other.methodElement &&
          name == other.name &&
          returnType == other.returnType &&
          flattenedReturnType == other.flattenedReturnType &&
          parameterElement == other.parameterElement &&
          entity == other.entity;

  @override
  int get hashCode =>
      methodElement.hashCode ^
      name.hashCode ^
      returnType.hashCode ^
      flattenedReturnType.hashCode ^
      parameterElement.hashCode ^
      entity.hashCode;
}
