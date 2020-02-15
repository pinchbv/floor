import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/view.dart';

class ViewProcessor extends Processor<View> {
  final ClassElement _classElement;
  final ViewProcessorError _processorError;

  ViewProcessor(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement,
        _processorError = ViewProcessorError(classElement);

  @nonNull
  @override
  View process() {
    final name = _getName();
    final fields = _getFields();
    final query = _getQuery();
    return View(
      _classElement,
      name,
      fields,
      query,
      _getConstructor(fields),
    );
  }

  @nonNull
  String _getName() {
    return _classElement
            .getAnnotation(annotations.DatabaseView)
            .getField(AnnotationField.VIEW_NAME)
            .toStringValue() ??
        _classElement.displayName;
  }

  @nonNull
  String _getQuery() {
    final query = _classElement
        .getAnnotation(annotations.DatabaseView)
        .getField(AnnotationField.VIEW_QUERY)
        .toStringValue();

    if (query == null || !query.toLowerCase().startsWith('select'))
      throw _processorError.MISSING_QUERY;
    return query;
  }

  @nonNull
  List<Field> _getFields() {
    return _classElement.fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field).process())
        .toList();
  }

  @nonNull
  String _getConstructor(final List<Field> fields) {
    final constructorParameters = _classElement.constructors.first.parameters;
    final parameterValues = constructorParameters
        .map((parameterElement) => _getParameterValue(parameterElement, fields))
        .where((parameterValue) => parameterValue != null)
        .join(', ');

    return '${_classElement.displayName}($parameterValues)';
  }

  /// Returns `null` whenever field is @ignored
  @nullable
  String _getParameterValue(
    final ParameterElement parameterElement,
    final List<Field> fields,
  ) {
    final parameterName = parameterElement.displayName;
    final field = fields.firstWhere(
      (field) => field.name == parameterName,
      orElse: () => null, // whenever field is @ignored
    );
    if (field != null) {
      final parameterValue = "row['${field.columnName}']";
      final castedParameterValue =
          _castParameterValue(parameterElement.type, parameterValue);
      if (parameterElement.isNamed) {
        return '$parameterName: $castedParameterValue';
      }
      return castedParameterValue; // also covers positional parameter
    } else {
      return null;
    }
  }

  @nonNull
  String _castParameterValue(
    final DartType parameterType,
    final String parameterValue,
  ) {
    if (parameterType.isDartCoreBool) {
      return '($parameterValue as int) != 0'; // maps int to bool
    } else if (parameterType.isDartCoreString) {
      return '$parameterValue as String';
    } else if (parameterType.isDartCoreInt) {
      return '$parameterValue as int';
    } else if (parameterType.getDisplayString() == 'Uint8List') {
      return '$parameterValue';
    } else {
      return '$parameterValue as double'; // must be double
    }
  }
}

extension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    final isHashCode = displayName == 'hashCode';
    return !(isStatic || isHashCode || isIgnored);
  }
}
