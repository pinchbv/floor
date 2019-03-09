import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:source_gen/source_gen.dart';

class FieldProcessor extends Processor<Field> {
  final FieldElement _fieldElement;

  FieldProcessor(final FieldElement fieldElement)
      : assert(fieldElement != null),
        _fieldElement = fieldElement;

  @override
  Field process() {
    final name = _fieldElement.name;
    final hasColumnInfoAnnotation =
        _fieldElement.metadata.any(isColumnInfoAnnotation);
    final columnName = _getColumnName(hasColumnInfoAnnotation, name);
    final isNullable = _getIsNullable(hasColumnInfoAnnotation);
    final isPrimaryKey = _fieldElement.metadata.any(isPrimaryKeyAnnotation);

    return Field(
      _fieldElement,
      name,
      columnName,
      isNullable,
      isPrimaryKey,
      _getSqlType(),
    );
  }

  String _getColumnName(bool hasColumnInfoAnnotation, String name) {
    return hasColumnInfoAnnotation
        ? _fieldElement.metadata
                .firstWhere(isColumnInfoAnnotation)
                .computeConstantValue()
                .getField(AnnotationField.COLUMN_INFO_NAME)
                .toStringValue() ??
            name
        : name;
  }

  bool _getIsNullable(bool hasColumnInfoAnnotation) {
    return hasColumnInfoAnnotation
        ? _fieldElement.metadata
                .firstWhere(isColumnInfoAnnotation)
                .computeConstantValue()
                .getField(AnnotationField.COLUMN_INFO_NULLABLE)
                .toBoolValue() ??
            true
        : true; // all Dart fields are nullable by default
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
