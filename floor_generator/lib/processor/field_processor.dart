import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
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
  final FieldElement2 _fieldElement;
  final TypeConverter? _typeConverter;

  FieldProcessor(
    final FieldElement2 fieldElement,
    final TypeConverter? typeConverter,
  )   : _fieldElement = fieldElement,
        _typeConverter = typeConverter;

  @override
  Field process() {
    final name = _fieldElement.displayName; //TODO 19.08.25: Name?
    final columnName = _getColumnName(name);
    final isNullable = _fieldElement.type.isNullable;
    final typeConverter =
        {..._fieldElement.getTypeConverters(TypeConverterScope.field), _typeConverter}.nonNulls.closestOrNull;

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
                ?.getField(AnnotationField.columnInfoName)
                ?.toStringValue() ??
            name
        : name;
  }

  String _getSqlType(final TypeConverter? typeConverter) {
    final type = _fieldElement.type;
    if (typeConverter != null) {
      return typeConverter.databaseType.asSqlType();
    } else if (type.isDefaultSqlType || type.isEnumType) {
      return type.asSqlType();
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
    } else if (isEnumType) {
      return SqlType.integer;
    }
    throw StateError('This should really be unreachable');
  }
}
