import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/view.dart';

class ViewProcessor extends QueryableProcessor<View> {
  ViewProcessor(
      final ClassElement classElement, final AnalyzerEngine analyzerEngine)
      : super(classElement, analyzerEngine);

  @nonNull
  @override
  View process() {
    final fields = getFields();
    final view = View(
      classElement,
      _getName(),
      fields,
      _getQuery(),
      getConstructor(fields),
    );

    analyzerEngine.checkAndRegisterView(view);

    return view;
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
