import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show ColumnInfo;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  final FieldElement _fieldElement;
  final String _prefix;

  FieldProcessor(final FieldElement fieldElement, [final String prefix = ''])
      : assert(fieldElement != null),
        assert(prefix != null),
        _fieldElement = fieldElement,
        _prefix = prefix;

  @nonNull
  @override
  Field process() {
    final name = _fieldElement.name;
    final hasColumnInfoAnnotation =
        _fieldElement.hasAnnotation(annotations.ColumnInfo);
    final columnName =
        '$_prefix${_getColumnName(hasColumnInfoAnnotation, name)}';
    final isNullable = _getIsNullable(hasColumnInfoAnnotation);

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      _getSqlType(),
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
    final type = _fieldElement.type;
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
      element: _fieldElement,
    );
  }
}
