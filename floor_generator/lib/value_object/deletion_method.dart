// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/change_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class DeletionMethod extends ChangeMethod {
  DeletionMethod(
    final MethodElement methodElement,
    final String name,
    final DartType returnType,
    final DartType flattenedReturnType,
    final ParameterElement parameterElement,
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
