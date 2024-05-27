import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/embeds_extension.dart';
import 'package:floor_generator/misc/extension/field_element_extension.dart';
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

import '../value_object/embed.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;

  final Set<TypeConverter> queryableTypeConverters;

  final Set<Embed> embedConverters;

  @protected
  QueryableProcessor(
    this.classElement,
    final Set<TypeConverter> typeConverters,
    this.embedConverters,
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
    ].where((fieldElement) => fieldElement.shouldBeIncluded());

    return fields.map((field) {
      if (field.isEmbedded) {
        return FieldProcessor(
                field, null, embedConverters.getClosestOrNull(field.type))
            .process();
      } else {
        return FieldProcessor(field,
                queryableTypeConverters.getClosestOrNull(field.type), null)
            .process();
      }
    }).toList();
  }

  @protected
  String getConstructor(final List<Field> fields) {
    return _getConstructor(classElement, fields);
  }

  String _getConstructor(ClassElement classElement, final List<Field> fields,
      {String prefix = ''}) {
    final constructorParameters = classElement.constructors
        .firstWhereOrNull((element) => element.isPublic && !element.isFactory)
        ?.parameters;

    if (constructorParameters == null) {
      throw _queryableProcessorError.missingUnnamedConstructor;
    } else {
      final parameterValues = constructorParameters
          .map((parameterElement) =>
              _getParameterValue(parameterElement, fields, prefix: prefix))
          .where((parameterValue) => parameterValue != null)
          .join(', ');

      return '${classElement.displayName}($parameterValues)';
    }
  }

  /// Returns `null` whenever field is @ignored
  String? _getParameterValue(
    final ParameterElement parameterElement,
    final List<Field> fields, {
    final String prefix = '',
  }) {
    final parameterName = parameterElement.displayName;
    final field = fields.firstWhereOrNull(
        (field) => field.fieldElement.displayName == parameterName);
    if (field != null) {
      final databaseValue = "row['$prefix${field.columnName}']";

      String parameterValue;
      if (parameterElement.type.isDefaultSqlType ||
          parameterElement.type.isEnumType) {
        parameterValue = databaseValue.cast(
          parameterElement.type,
          parameterElement,
        );
      } else if (field.embedConverter != null) {
        final embedVar = field.columnName.isEmpty ? '' : '${field.columnName}_';
        parameterValue = _getConstructor(
            field.embedConverter!.classElement, field.embedConverter!.fields,
            prefix: '$prefix$embedVar');
      } else {
        final typeConverter = [
          ...queryableTypeConverters,
          field.typeConverter,
        ].whereNotNull().getClosest(parameterElement.type);

        final castedDatabaseValue = databaseValue.cast(
          typeConverter.databaseType,
          parameterElement,
        );

        parameterValue =
            '_${typeConverter.name.decapitalize()}.decode($castedDatabaseValue)';
      }

      if (parameterElement.isNamed) {
        return '$parameterName: $parameterValue';
      }
      return parameterValue; // also covers positional parameter
    }
    return null;
  }
}
