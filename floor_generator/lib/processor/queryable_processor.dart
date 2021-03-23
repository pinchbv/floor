// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
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
  List<Field> getFieldsWithOutCheckIgnore() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }
    final fields = [
      ...classElement.fields,
      ...classElement.allSupertypes.expand((type) => type.element.fields),
    ];

    return fields
        .where((fieldElement) => fieldElement.shouldBeIncludedAnyOperation())
        .map((field) {
      final typeConverter =
          queryableTypeConverters.getClosestOrNull(field.type);
      return FieldProcessor(field, typeConverter).process();
    }).toList();
  }

  @protected
  List<FieldElement> getFieldsSub() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }
    final fields = [
      ...classElement.fields,
      ...classElement.allSupertypes.expand((type) => type.element.fields),
    ];

    return fields
        .where((fieldElement) => fieldElement.shouldBeIncludedSub())
        .toList();
  }

  @protected
  List<FieldElement> getFieldsOutsideConstructor() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }
    final fields = [
      ...classElement.fields,
      ...classElement.allSupertypes.expand((type) => type.element.fields),
    ];

    final constructorParameters = classElement.constructors.first.parameters.where((e) => fields.any((f) => e.displayName == f.displayName) );

    return fields
        .where((fieldElement) => fieldElement.shouldBeIncludedForQuery() && constructorParameters.every((e) => e.name != fieldElement.name))
        .toList();
  }

  String _getValueMappingOutsideConstructor(final List<Field> fields, List<FieldElement> fieldsOutsideConstructor) {
    final keyValueList = fieldsOutsideConstructor.map((fieldElement) {
      final parameterName = fieldElement.displayName;
      final field = fields.firstWhere((field) => field.name == parameterName);
      final columnName = field.columnName;
      final attributeValue = _getAttributeValue(fieldElement, field);
      return '..$columnName = $attributeValue';
    }).toList();

    return keyValueList.join('\n');
  }
  String _getAttributeValue(FieldElement parameterElement, Field field) {
      final databaseValue = "row['${field.columnName}']";

      String parameterValue;

      if (parameterElement.type.isDefaultSqlType) {
        parameterValue = databaseValue.cast(
          parameterElement.type,
          field.isNullable,
          parameterElement,
        );
      } else if (parameterElement.type.element is ClassElement && (parameterElement.type.element as ClassElement).isEnum) {
        if (field.isNullable) {
          parameterValue = '$databaseValue == null ? null : ${parameterElement.type.element?.displayName}.values.firstWhere((e) => e.value == $databaseValue)';
        } else{
          parameterValue = '${parameterElement.type.element?.displayName}.values.firstWhere((e) => e.value == $databaseValue)';
        }
      } else {
        final typeConverter = [...queryableTypeConverters, field.typeConverter]
            .whereNotNull()
            .getClosest(parameterElement.type);
        final castedDatabaseValue = databaseValue.cast(
          typeConverter.databaseType,
          field.isNullable,
          parameterElement,
        );

        parameterValue =
        '_${typeConverter.name.decapitalize()}.decode($castedDatabaseValue)';
      }
      return parameterValue; // also covers positional parameter
  }

  @protected
  String getConstructor(final List<Field> fields) {
    final constructorParameters = classElement.constructors.first.parameters;
    final parameterValues = constructorParameters
        .map((parameterElement) => _getParameterValue(parameterElement, fields))
        .where((parameterValue) => parameterValue != null)
        .join(', ');

    final fieldsOutsideConstructor = getFieldsOutsideConstructor();
    final valueMappingOutsideConstructor = _getValueMappingOutsideConstructor(fields, fieldsOutsideConstructor);

    return '${classElement.displayName}($parameterValues)$valueMappingOutsideConstructor';
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

      if (parameterElement.type.isDefaultSqlType) {
        parameterValue = databaseValue.cast(
          parameterElement.type,
          field.isNullable,
          parameterElement,
        );
      } else if (parameterElement.type.element is ClassElement && (parameterElement.type.element as ClassElement).isEnum) {
        if (field.isNullable) {
          parameterValue = '$databaseValue == null ? null : ${parameterElement.type.element?.displayName}.values.firstWhere((e) => e.value == $databaseValue)';
        } else{
          parameterValue = '${parameterElement.type.element?.displayName}.values.firstWhere((e) => e.value == $databaseValue)';
        }
      } else {
        final typeConverter = [...queryableTypeConverters, field.typeConverter]
            .whereNotNull()
            .getClosest(parameterElement.type);
        final castedDatabaseValue = databaseValue.cast(
          typeConverter.databaseType,
          field.isNullable,
          parameterElement,
        );

        parameterValue =
            '_${typeConverter.name.decapitalize()}.decode($castedDatabaseValue)';
      }

      if (parameterElement.isNamed) {
        return '$parameterName: $parameterValue';
      }
      return parameterValue; // also covers positional parameter
    } else {
      return null;
    }
  }

  @protected
  bool shouldBeIncludedAnyOperation(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedAnyOperation();
  }

  @protected
  bool shouldBeIncludedForDataBaseSchema(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedForDataBaseSchema();
  }

  @protected
  bool shouldBeIncludedForQuery(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedForQuery();
  }

  @protected
  bool shouldBeIncludedForInsert(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedForInsert();
  }

  @protected
  bool shouldBeIncludedForUpdate(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedForUpdate();
  }

  @protected
  bool shouldBeIncludedForDelete(FieldElement fieldElement) {
    return fieldElement.shouldBeIncludedForDelete();
  }
}

extension on String {
  String cast(
    DartType dartType,
    bool isNullable,
      VariableElement parameterElement,
  ) {
    if (dartType.isDartCoreBool) {
      if (isNullable) {
        // if the value is null, return null
        // if the value is not null, interpret 1 as true and 0 as false
        return '$this == null ? null : ($this as int) != 0';
      } else {
        return '($this as int) != 0';
      }
    } else if (dartType.isDartCoreString) {
      return '$this as String${isNullable ? '?' : ''}';
    } else if (dartType.isDartCoreInt) {
      return '$this as int${isNullable ? '?' : ''}';
    } else if (dartType.isUint8List) {
      return '$this as Uint8List${isNullable ? '?' : ''}';
    } else if (dartType.isDartCoreDouble) {
      return '$this as double${isNullable ? '?' : ''}';
    } else {
      throw InvalidGenerationSourceError(
        'Trying to convert unsupported type $dartType.',
        todo: 'Consider adding a type converter.',
        element: parameterElement,
      );
    }
  }
}

extension on FieldElement {
  bool shouldBeIncludedAnyOperation() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forQuery)!.toBoolValue()! ||
        !ignoreAnnotation.getField(IgnoreField.forInsert)!.toBoolValue()! ||
        !ignoreAnnotation.getField(IgnoreField.forUpdate)!.toBoolValue()! ||
        !ignoreAnnotation.getField(IgnoreField.forDelete)!.toBoolValue()!;
  }

  bool shouldBeIncludedForQuery() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forQuery)!.toBoolValue()!;
  }

  bool shouldBeIncludedForInsert() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forInsert)!.toBoolValue()!;
  }

  bool shouldBeIncludedForUpdate() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forUpdate)!.toBoolValue()!;
  }

  bool shouldBeIncludedForDelete() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forDelete)!.toBoolValue()!;
  }

  bool shouldBeIncludedForDataBaseSchema() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (!isIgnored) {
      return true;
    }
    final ignoreAnnotation = getAnnotation(annotations.Ignore);
    return !ignoreAnnotation.getField(IgnoreField.forInsert)!.toBoolValue()! ||
        !ignoreAnnotation.getField(IgnoreField.forUpdate)!.toBoolValue()! ||
        !ignoreAnnotation.getField(IgnoreField.forDelete)!.toBoolValue()!
    ;
  }

  bool shouldBeIncludedSub() {
    if (isStatic || isSynthetic) {
      return false;
    }
    final isSub = hasAnnotation(annotations.sub.runtimeType);
    if (!isSub) {
      return false;
    }

    final isIgnored = hasAnnotation(annotations.Ignore);
    if (isIgnored) {
      throw InvalidGenerationSourceError(
        'Skip element and sub feature cannot be used in the same field.',
        todo: 'Consider remove @ignore.',
        element: this,
      );
    }
    return true;
  }
}
