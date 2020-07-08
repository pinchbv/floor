import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:meta/meta.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;

  @protected
  final AnalyzerEngine analyzerEngine;

  @protected
  QueryableProcessor(this.classElement, this.analyzerEngine)
      : assert(classElement != null),
        _queryableProcessorError = QueryableProcessorError(classElement);

  @nonNull
  @protected
  List<Field> getFields() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }
    final fields = [
      ...classElement.fields,
      ...classElement.allSupertypes.expand((type) => type.element.fields),
    ];

    return fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field).process())
        .toList();
  }

  @nonNull
  @protected
  String getConstructor(final List<Field> fields) {
    final constructorParameters = classElement.constructors.first.parameters;
    final parameterValues = constructorParameters
        .map((parameterElement) => _getParameterValue(parameterElement, fields))
        .where((parameterValue) => parameterValue != null)
        .join(', ');

    return '${classElement.displayName}($parameterValues)';
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
      final castedParameterValue = _castParameterValue(
          parameterElement.type, parameterValue, field.isNullable);
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
    final bool isNullable,
  ) {
    if (parameterType.isDartCoreBool) {
      if (isNullable) {
        // maps int to bool
        // if the value is null, return null. If the value is not null, interpret 1 as true and 0 as false.
        return '$parameterValue == null ? null : ($parameterValue as int) != 0';
      } else {
        return '($parameterValue as int) != 0'; // maps int to bool
      }
    } else if (parameterType.isDartCoreString) {
      return '$parameterValue as String';
    } else if (parameterType.isDartCoreInt) {
      return '$parameterValue as int';
    } else if (parameterType.isUint8List) {
      return '$parameterValue as Uint8List';
    } else {
      return '$parameterValue as double'; // must be double
    }
  }
}

extension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    return !(isStatic || isSynthetic || isIgnored);
  }
}
