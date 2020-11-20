// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
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
    final hasColumnInfoAnnotation =
        _fieldElement.hasAnnotation(annotations.ColumnInfo);
    final columnName = _getColumnName(hasColumnInfoAnnotation, name);
    final isNullable = _getIsNullable(hasColumnInfoAnnotation);
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

  String _getColumnName(bool hasColumnInfoAnnotation, String name) {
    return hasColumnInfoAnnotation
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                .getField(AnnotationField.columnInfoName)
                ?.toStringValue() ??
            name
        : name;
  }

  bool _getIsNullable(bool hasColumnInfoAnnotation) {
    return hasColumnInfoAnnotation
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                .getField(AnnotationField.columnInfoNullable)
                ?.toBoolValue() ??
            true
        : true; // all Dart fields are nullable by default
  }

  String _getSqlType(final TypeConverter? typeConverter) {
    final type = _fieldElement.type;
    if (type.isDefaultSqlType) {
      return type.asSqlType();
    } else if (typeConverter != null) {
      return typeConverter.databaseType.asSqlType();
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
