import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:flat_generator/misc/extension/class_element_extension.dart';
import 'package:flat_generator/misc/extension/dart_type_extension.dart';
import 'package:flat_generator/misc/extension/field_element_extension.dart';
import 'package:flat_generator/misc/extension/set_extension.dart';
import 'package:flat_generator/misc/extension/string_extension.dart';
import 'package:flat_generator/misc/extension/type_converter_element_extension.dart';
import 'package:flat_generator/misc/extension/type_converters_extension.dart';
import 'package:flat_generator/misc/type_utils.dart';
import 'package:flat_generator/processor/embedded_processor.dart';
import 'package:flat_generator/processor/error/queryable_processor_error.dart';
import 'package:flat_generator/processor/field_processor.dart';
import 'package:flat_generator/processor/processor.dart';
import 'package:flat_generator/value_object/embedded.dart';
import 'package:flat_generator/value_object/field.dart';
import 'package:flat_generator/value_object/queryable.dart';
import 'package:flat_generator/value_object/type_converter.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;

  final Set<TypeConverter> queryableTypeConverters;

  late final List<FieldElement> _fieldElements = _getFieldElements();

  @protected
  QueryableProcessor(
    this.classElement,
    final Set<TypeConverter> typeConverters,
  )   : _queryableProcessorError = QueryableProcessorError(classElement),
        queryableTypeConverters = typeConverters +
            classElement.getTypeConverters(TypeConverterScope.queryable);

  List<FieldElement> _getFieldElements() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }
    return classElement.getFields().toList();
  }

  @protected
  List<Field> getFields() => _fieldElements
          .where((fieldElement) => !fieldElement.isEmbedded())
          .map((field) {
        final typeConverter =
            queryableTypeConverters.getClosestOrNull(field.type);
        return FieldProcessor(field, typeConverter).process();
      }).toList();

  @protected
  List<Embedded> getEmbedded() => _fieldElements
          .where((fieldElement) => fieldElement.isEmbedded())
          .map((embedded) {
        final typeConverters = queryableTypeConverters +
            embedded.type.element!
                .getTypeConverters(TypeConverterScope.embedded);
        return EmbeddedProcessor(embedded, typeConverters).process();
      }).toList();

  @protected
  String getConstructor(final List<FieldBase> fields) =>
      _getConstructor(classElement, fields);

  String _getConstructor(
      final ClassElement classElement, final List<FieldBase> fields) {
    final constructorParameters = classElement.constructors.first.parameters;
    final parameterValues = constructorParameters
        .map((parameterElement) => _getParameterValue(parameterElement, fields))
        .where((parameterValue) => parameterValue != null)
        .join(', ');

    return '${classElement.displayName}($parameterValues)';
  }

  /// Returns `null` whenever field is @ignored
  String? _getParameterValue(
    final ParameterElement parameterElement,
    final List<FieldBase> fields,
  ) {
    final parameterName = parameterElement.displayName;
    final field =
        // null whenever field is @ignored
        fields.firstWhereOrNull((field) => field.name == parameterName);
    if (field != null) {
      String parameterValue;
      if (field is Field) {
        final databaseValue = "row['${field.columnName}']";
        if (parameterElement.type.isDefaultSqlType) {
          parameterValue = databaseValue.cast(
            parameterElement.type,
            parameterElement,
          );
        } else {
          final typeConverter = [
            ...queryableTypeConverters,
            field.typeConverter
          ].whereNotNull().getClosest(parameterElement.type);
          final castedDatabaseValue = databaseValue.cast(
            typeConverter.databaseType,
            parameterElement,
          );

          parameterValue =
              '_${typeConverter.name.decapitalize()}.decode($castedDatabaseValue)';
        }
      } else {
        final embedded = field as Embedded;
        parameterValue = _getConstructor(
            embedded.classElement, [...embedded.fields, ...embedded.embedded]);
        if (embedded.isNullable) {
          parameterValue = embedded
                  .getAllFields()
                  .map((e) => "row['${e.columnName}'] != null")
                  .join(' || ') +
              ' ? ' +
              parameterValue +
              ' : null';
        }
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
  String cast(DartType dartType, ParameterElement parameterElement) {
    if (dartType.isDartCoreBool) {
      if (dartType.isNullable) {
        // if the value is null, return null
        // if the value is not null, interpret 1 as true and 0 as false
        return '$this == null ? null : ($this as int) != 0';
      } else {
        return '($this as int) != 0';
      }
    } else if (dartType.isDartCoreString ||
        dartType.isDartCoreInt ||
        dartType.isUint8List ||
        dartType.isDartCoreDouble) {
      final typeString = dartType.getDisplayString(withNullability: true);
      return '$this as $typeString';
    } else {
      throw InvalidGenerationSourceError(
        'Trying to convert unsupported type $dartType.',
        todo: 'Consider adding a type converter.',
        element: parameterElement,
      );
    }
  }
}
