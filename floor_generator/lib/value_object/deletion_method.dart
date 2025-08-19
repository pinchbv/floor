import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/change_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class DeletionMethod extends ChangeMethod {
  DeletionMethod(
    final MethodElement2 methodElement,
    final String name,
    final DartType returnType,
    final DartType flattenedReturnType,
    final FormalParameterElement parameterElement,
    final Entity entity,
  ) : super(
          methodElement,
          name,
          returnType,
          flattenedReturnType,
          parameterElement,
          entity,
        );

  @override
  String toString() {
    return 'DeletionMethod{methodElement: $methodElement, name: $name, returnType: $returnType, flattenedReturnType: $flattenedReturnType, parameterElement: $parameterElement, entity: $entity}';
  }
}
