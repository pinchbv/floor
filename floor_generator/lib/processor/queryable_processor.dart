import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:meta/meta.dart';

abstract class QueryableProcessor<T> extends Processor<T> {
  @protected
  final ClassElement classElement;

  @protected
  QueryableProcessor(this.classElement) : assert(classElement != null);

  @nonNull
  @protected
  List<Field> getFields() {
    return classElement.fields
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
    final isHashCode = displayName == 'hashCode';
    return !(isStatic || isHashCode || isIgnored);
  }
}
