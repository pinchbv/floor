import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extensions/type_converter_element_extension.dart';
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

    final allTypeConverters =
        _fieldElement.getTypeConverters(TypeConverterScope.field);
    if (_typeConverter != null) allTypeConverters.add(_typeConverter);

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      _getSqlType(),
      allTypeConverters,
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
  String _getSqlType() {
    DartType type = _fieldElement.type;

    if (!type.isDefaultSqlType && _typeConverter != null) {
      type = _typeConverter.databaseType;
    }

    // TODO #165 make this nicer
    if (!type.isDefaultSqlType && _typeConverter == null) {
      throw InvalidGenerationSourceError(
        'Column type is not supported for $type.',
        todo: 'Either make to use a supported type or supply a type converter.',
        element: _fieldElement,
      );
    }

    if (type.isDartCoreInt) {
      return SqlType.integer;
    } else if (type.isDartCoreString) {
      return SqlType.text;
    } else if (type.isDartCoreBool) {
      return SqlType.integer;
    } else if (type.isDartCoreDouble) {
      return SqlType.real;
    } else if (type.isUint8List) {
      return SqlType.blob;
    }
    throw InvalidGenerationSourceError(
      'Column type is not supported for $type.',
      todo: 'Either make to use a supported type or supply a type converter.',
      element: _fieldElement,
    );
  }
}
