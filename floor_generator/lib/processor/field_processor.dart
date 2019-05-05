import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show ColumnInfo, PrimaryKey;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  final FieldElement _fieldElement;

  final _columnInfoTypeChecker = typeChecker(annotations.ColumnInfo);

  FieldProcessor(final FieldElement fieldElement)
      : assert(fieldElement != null),
        _fieldElement = fieldElement;

  @override
  Field process() {
    final name = _fieldElement.name;
    final hasColumnInfoAnnotation =
        _columnInfoTypeChecker.hasAnnotationOfExact(_fieldElement);
    final columnName = _getColumnName(hasColumnInfoAnnotation, name);
    final isNullable = _getIsNullable(hasColumnInfoAnnotation);
    final readOnly = _getReadOnly(hasColumnInfoAnnotation);
    final isPrimaryKey =
        typeChecker(annotations.PrimaryKey).hasAnnotationOfExact(_fieldElement);

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      readOnly,
      isPrimaryKey,
      _getSqlType(),
    );
  }

  String _getColumnName(bool hasColumnInfoAnnotation, String name) {
    return hasColumnInfoAnnotation
        ? _columnInfoTypeChecker
                .firstAnnotationOfExact(_fieldElement)
                .getField(AnnotationField.COLUMN_INFO_NAME)
                ?.toStringValue() ??
            name
        : name;
  }

  bool _getIsNullable(bool hasColumnInfoAnnotation) {
    return hasColumnInfoAnnotation
        ? _columnInfoTypeChecker
                .firstAnnotationOfExact(_fieldElement)
                .getField(AnnotationField.COLUMN_INFO_NULLABLE)
                ?.toBoolValue() ??
            true
        : true; // all Dart fields are nullable by default
  }

  bool _getReadOnly(bool hasColumnInfoAnnotation) {
    return hasColumnInfoAnnotation
        ? _columnInfoTypeChecker
                .firstAnnotationOfExact(_fieldElement)
                .getField(AnnotationField.COLUMN_INFO_READ_ONLY)
                ?.toBoolValue() ??
            false
        : false; // all Dart fields are not read only by default
  }

  String _getSqlType() {
    final type = _fieldElement.type;
    if (isInt(type)) {
      return SqlType.INTEGER;
    } else if (isString(type)) {
      return SqlType.TEXT;
    } else if (isBool(type)) {
      return SqlType.INTEGER;
    } else if (isDouble(type)) {
      return SqlType.REAL;
    }
    throw InvalidGenerationSourceError(
      'Column type is not supported for $type.',
      element: _fieldElement,
    );
  }
}
