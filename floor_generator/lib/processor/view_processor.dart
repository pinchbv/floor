import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/value_object/view.dart';

class ViewProcessor extends QueryableProcessor<View> {
  final ViewProcessorError _processorError;

  ViewProcessor(
    final ClassElement classElement,
    final Set<TypeConverter> typeConverters,
  )   : _processorError = ViewProcessorError(classElement),
        super(classElement, typeConverters);

  @override
  View process() {
    final fieldsAll = getFieldsWithOutCheckIgnore();
    final fieldsQuery = fieldsAll.where((e) => shouldBeIncludedForQuery(e.fieldElement)).toList();
    final fieldsDataBase = fieldsAll.where((e) => shouldBeIncludedForDataBase(e.fieldElement)).toList();
    return View(
      classElement,
      _getName(),
      fieldsQuery,
      fieldsDataBase,
      fieldsAll,
      _getQuery(),
      getConstructor(fieldsQuery),
    );
  }

  String _getName() {
    return classElement
            .getAnnotation(annotations.DatabaseView)
            .getField(AnnotationField.viewName)
            ?.toStringValue() ??
        classElement.displayName;
  }

  String _getQuery() {
    final query = classElement
        .getAnnotation(annotations.DatabaseView)
        .getField(AnnotationField.viewQuery)
        ?.toStringValue();

    if (query == null || !(query.isSelectQuery || query.isCteWithSelect)) {
      throw _processorError.missingQuery;
    }
    return query;
  }
}

extension on String {
  bool get isSelectQuery => toLowerCase().trimLeft().startsWith('select');

  /// whether the string is a common table expression
  /// followed by a `SELECT` query
  bool get isCteWithSelect {
    final lowerCasedString = toLowerCase();
    return lowerCasedString.trimLeft().startsWith('with') &&
        'select'.allMatches(lowerCasedString).length >= 2;
  }
}
