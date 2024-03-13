import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/extension/set_extension.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;

  final Set<TypeConverter> queryableTypeConverters;

  @protected
  QueryableProcessor(
    this.classElement,
    final Set<TypeConverter> typeConverters,
  )   : _queryableProcessorError = QueryableProcessorError(classElement),
        queryableTypeConverters = typeConverters +
            classElement.getTypeConverters(TypeConverterScope.queryable);

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

  @protected
  String getConstructor(final List<Field> fields) {
    final constructorParameters = classElement.constructors
        .firstWhereOrNull((element) => element.isPublic && !element.isFactory)
        ?.parameters;

    if (constructorParameters == null) {
      throw _queryableProcessorError.missingUnnamedConstructor;
    } else {
      final parameterValues = constructorParameters
          .map((parameterElement) =>
              _getParameterValue(parameterElement, fields))
          .where((parameterValue) => parameterValue != null)
          .join(', ');

      return '${classElement.displayName}($parameterValues)';
    }
  }

  /// Returns `null` whenever field is @ignored
  String? _getParameterValue(
    final ParameterElement parameterElement,
    final List<Field> fields,
  ) {
    final parameterName = parameterElement.displayName;
    final field =
        // null whenever field is @ignored
        fields.firstWhereOrNull((field) => field.name == parameterName);
    if (field != null) {
      final databaseValue = "row['${field.columnName}']";

      String parameterValue;

      final typeConverter = [...queryableTypeConverters, field.typeConverter]
          .whereNotNull()
          .getClosestOrNull(parameterElement.type);

      if (typeConverter != null) {
        final castedDatabaseValue = databaseValue.cast(
          typeConverter.databaseType,
          parameterElement,
        );

        parameterValue =
            '_${typeConverter.name.decapitalize()}.decode($castedDatabaseValue)';
      } else if (parameterElement.type.isDefaultSqlType ||
          parameterElement.type.isEnumType) {
        parameterValue = databaseValue.cast(
          parameterElement.type,
          parameterElement,
        );
      } else {
        throw InvalidGenerationSourceError(
          'Column type is not supported for ${parameterElement.type}',
          todo:
              'Either use a supported type https://pinchbv.github.io/floor/entities/#supported-types or supply a type converter.',
        );
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

extension on FieldElement {
  bool shouldBeIncluded() {
    final isIgnored = hasAnnotation(annotations.ignore.runtimeType);
    return !(isStatic || isSynthetic || isIgnored);
  }
}
