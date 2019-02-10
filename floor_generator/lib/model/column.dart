import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';

/// Represents a table column.
class Column {
  final FieldElement field;

  Column(this.field);

  String get name {
    if (!_hasColumnInfoAnnotation) {
      return field.displayName;
    }
    return field.metadata
            .firstWhere(isColumnInfoAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.COLUMN_INFO_NAME)
            .toStringValue() ??
        field.displayName;
  }

  bool get isNullable {
    if (!_hasColumnInfoAnnotation) {
      return true; // all Dart fields are nullable by default
    }
    return field.metadata
            .firstWhere(isColumnInfoAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.COLUMN_INFO_NULLABLE)
            .toBoolValue() ??
        true;
  }

  bool get _hasColumnInfoAnnotation {
    return field.metadata.any(isColumnInfoAnnotation);
  }

  String get type {
    final type = field.type;
    if (isInt(type)) {
      return SqlConstants.INTEGER;
    } else if (isString(type)) {
      return SqlConstants.INTEGER;
    } else if (isBool(type)) {
      return SqlConstants.INTEGER;
    } else if (isDouble(type)) {
      return SqlConstants.REAL;
    }
    throw InvalidGenerationSourceError(
      'Column type is not supported for $type.',
      element: field,
    );
  }

  bool get isPrimaryKey => field.metadata.any(isPrimaryKeyAnnotation);

  bool get _autoGenerate {
    if (!isPrimaryKey) {
      return null;
    }
    return field.metadata
            .firstWhere(isPrimaryKeyAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.PRIMARY_KEY_AUTO_GENERATE)
            .toBoolValue() ??
        false;
  }

  /// Primary key and auto increment.
  String get additionals {
    String add = '';

    if (isPrimaryKey) {
      add += ' ${SqlConstants.PRIMARY_KEY}';
      if (_autoGenerate) {
        add += ' ${SqlConstants.AUTOINCREMENT}';
      }
    }

    if (add.isEmpty) {
      return null;
    }
    return add;
  }
}
