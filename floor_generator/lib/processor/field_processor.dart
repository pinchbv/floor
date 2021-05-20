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
import 'package:floor_generator/value_object/embed.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  final FieldElement _fieldElement;
  final TypeConverter? _typeConverter;
  final Embed? _embedConverter;

  FieldProcessor(
    this._fieldElement,
    this._typeConverter,
    this._embedConverter,
  );

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
      _getSqlType(typeConverter, _embedConverter),
      typeConverter,
      _embedConverter,
    );
  }

  String _getColumnName(final String name) {
    return _fieldElement.hasAnnotation(annotations.ColumnInfo)
        ? _fieldElement
                .getAnnotation(annotations.ColumnInfo)
                ?.getField(AnnotationField.columnInfoName)
                ?.toStringValue() ?? name
        : name;
  }

  String _getSqlType(final TypeConverter? typeConverter, final Embed? embedConverter) {
    final type = _fieldElement.type;
    if (type.isDefaultSqlType) {
      return type.asSqlType();
    } else if (typeConverter != null) {
      return typeConverter.databaseType.asSqlType();
    } else if (embedConverter != null) {
      return '';
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
