import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  @nonNull
  final FieldElement _fieldElement;
  @nullable
  final TypeConverter _typeConverter;

  FieldProcessor(
    @nonNull final FieldElement fieldElement,
    @nullable final TypeConverter typeConverter,
  )   : assert(fieldElement != null),
        _fieldElement = fieldElement,
        _typeConverter = typeConverter;

  @nonNull
  @override
  Field process() {
    final name = _fieldElement.name;
    final hasColumnInfoAnnotation =
        _fieldElement.hasAnnotation(annotations.ColumnInfo);
    final columnName = _getColumnName(hasColumnInfoAnnotation, name);
    final isNullable = _getIsNullable(hasColumnInfoAnnotation);
    final typeConverter = [
      ..._fieldElement.getTypeConverters(TypeConverterScope.field),
      _typeConverter
    ].filterNotNull().closestOrNull;

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      _getSqlType(typeConverter),
      typeConverter,
    );
  }

  @nonNull
  String _getColumnName(bool hasColumnInfoAnnotation, String name) {
    return hasColumnInfoAnnotation
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                .getField(AnnotationField.columnInfoName)
                ?.toStringValue() ??
            name
        : name;
  }

  @nonNull
  bool _getIsNullable(bool hasColumnInfoAnnotation) {
    return hasColumnInfoAnnotation
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                .getField(AnnotationField.columnInfoNullable)
                ?.toBoolValue() ??
            true
        : true; // all Dart fields are nullable by default
  }

  @nonNull
  String _getSqlType(@nullable final TypeConverter typeConverter) {
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
