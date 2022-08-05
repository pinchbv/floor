import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show OnConflictStrategy;
import 'package:floor_generator/misc/constants.dart';
import 'package:source_gen/source_gen.dart';

class ChangeMethodProcessorError {
  final MethodElement _methodElement;
  final String _methodType;

  ChangeMethodProcessorError(this._methodElement, this._methodType);

  InvalidGenerationSourceError get doesNotReturnVoidNorInt =>
      InvalidGenerationSourceError(
        '$_methodType methods have to return a Future of either void or int.',
        element: _methodElement,
      );

  InvalidGenerationSourceError get doesNotReturnFuture =>
      InvalidGenerationSourceError(
        '$_methodType methods have to return a Future.',
        element: _methodElement,
      );

  InvalidGenerationSourceError get shouldNotReturnList =>
      InvalidGenerationSourceError(
        '$_methodType methods have to return a Future of either void or int but not a list.',
        element: _methodElement,
      );
  InvalidGenerationSourceError get doesNotReturnVoidNorIntNorListInt =>
      InvalidGenerationSourceError(
        '$_methodType methods have to return a Future of either void, int or List<int>.',
        element: _methodElement,
      );
  InvalidGenerationSourceError get wrongOnConflictValue =>
      InvalidGenerationSourceError(
        'Value of ${AnnotationField.onConflict} must be one of ${annotations.OnConflictStrategy.values.map((e) => e.toString()).join(',')}',
        element: _methodElement,
      );
}
