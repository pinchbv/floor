import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/extensions/type_converter_element_extension.dart';
import 'package:floor_generator/misc/extensions/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:meta/meta.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;

  final List<TypeConverter> queryableTypeConverters;

  @protected
  QueryableProcessor(
    this.classElement,
    final List<TypeConverter> typeConverters,
  )   : assert(classElement != null),
        assert(typeConverters != null),
        _queryableProcessorError = QueryableProcessorError(classElement),
        queryableTypeConverters = typeConverters +
            classElement.getTypeConverters(TypeConverterScope.queryable);

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
        .map((field) {
      final typeConverter =
          queryableTypeConverters.getClosestOrNull(field.type);
      return FieldProcessor(field, typeConverter).process();
    }).toList();
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
      final databaseValue = "row['${field.columnName}']";

      String parameterValue;

      if (!parameterElement.type.isDefaultSqlType) {
        final typeConverter = [...queryableTypeConverters, field.typeConverter]
            .filterNotNull()
            .getClosest(parameterElement.type);
        final castedDatabaseValue =
            databaseValue.asType(typeConverter.databaseType);

        parameterValue = '${typeConverter.name}().decode($castedDatabaseValue)';
      } else {
        parameterValue = databaseValue.asType(parameterElement.type);
      }

      if (parameterElement.isNamed) {
        return '$parameterName: $parameterValue';
      }
      return parameterValue; // also covers positional parameter
    } else {
      return null;
    }
  }
}

extension on String {
  String asType(DartType dartType) {
    if (dartType.isDartCoreBool) {
      return '($this as int) != 0'; // maps int to bool
    } else if (dartType.isDartCoreString) {
      return '$this as String';
    } else if (dartType.isDartCoreInt) {
      return '$this as int';
    } else if (dartType.isUint8List) {
      return '$this as Uint8List';
    } else {
      return '$this as double'; // must be double
    }
  }
}

extension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    return !(isStatic || isSynthetic || isIgnored);
  }
}
