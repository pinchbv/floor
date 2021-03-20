// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  final FieldElement _fieldElement;
  final TypeConverter? _typeConverter;

  FieldProcessor(
    final FieldElement fieldElement,
    final TypeConverter? typeConverter,
  )   : _fieldElement = fieldElement,
        _typeConverter = typeConverter;

  @override
  Field process() {
    final name = _fieldElement.name;
    final columnName = _getColumnName(name);
    final isNullable = _fieldElement.type.isNullable;
    final typeConverter = {
      ..._fieldElement.getTypeConverters(TypeConverterScope.field),
      _typeConverter
    }.whereNotNull().closestOrNull;

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      _getSqlType(typeConverter),
      typeConverter,
    );
  }

  String _getColumnName(final String name) {
    return _fieldElement.hasAnnotation(annotations.ColumnInfo)
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                .getField(AnnotationField.columnInfoName)
                ?.toStringValue() ??
            name
        : name;
  }

  String _getSqlType(final TypeConverter? typeConverter) {
    final type = _fieldElement.type;
    if (type.isDefaultSqlType) {
      return type.asSqlType();
    } else if (typeConverter != null) {
      return typeConverter.databaseType.asSqlType();
    } else if (type.element is ClassElement && (type.element as ClassElement).isEnum) {
      final classElement = type.element as ClassElement;
      final typeOfEnum = classElement.typeOfEnum();
      if (typeOfEnum == null) {
        throw InvalidGenerationSourceError(
          'Enum type $type must be defined the values through the @EnumValue annotation, it cannot have different data types for the same enum.',
          todo: 'Put @EnumValue in all enums for type $type, all values must be of the same type.',
          element: _fieldElement,
        );
      }
      return typeOfEnum.asSqlType();
    } else {
      throw InvalidGenerationSourceError(
        'Column type is not supported for $type.',
        todo: 'Either make to use a supported type or supply a type converter.',
        element: _fieldElement,
      );
    }
  }
}

extension on DartType {
  String asSqlType() {
    if (isDartCoreInt) {
      return SqlType.integer;
    } else if (isDartCoreString) {
      return SqlType.text;
    } else if (isDartCoreBool) {
      return SqlType.integer;
    } else if (isDartCoreDouble) {
      return SqlType.real;
    } else if (isUint8List) {
      return SqlType.blob;
    }
    throw StateError('This should really be unreachable');
  }
}
