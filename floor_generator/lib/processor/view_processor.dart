import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/view.dart';

class ViewProcessor extends QueryableProcessor<View> {
  final ViewProcessorError _processorError;

  ViewProcessor(final ClassElement classElement)
      : _processorError = ViewProcessorError(classElement),
        super(classElement);

  @nonNull
  @override
  View process() {
    final fields = getFields();
    return View(
      classElement,
      _getName(),
      fields,
      _getQuery(),
      getConstructor(fields),
    );
  }

  @nonNull
  String _getName() {
    return classElement
            .getAnnotation(annotations.DatabaseView)
            .getField(AnnotationField.viewName)
            ?.toStringValue() ??
        classElement.displayName;
  }

  @nonNull
  String _getQuery() {
    return classElement
        .getAnnotation(annotations.DatabaseView)
        .getField(AnnotationField.viewQuery)
        ?.toStringValue();
  }
}
