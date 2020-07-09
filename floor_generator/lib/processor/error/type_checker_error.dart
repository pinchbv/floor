import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class TypeCheckerError {
  final Element _queryElement;

  TypeCheckerError(this._queryElement);

  InvalidGenerationSourceError columnCountMismatch(
    int fieldCount,
    int columnCount,
  ) {
    return InvalidGenerationSourceError(
      'The query should return the same amount of columns($columnCount) as the target($fieldCount).',
      todo: 'Either change the target type or alter your query.',
      element: _queryElement,
    );
  }

  InvalidGenerationSourceError columnCountShouldBeOne(int columnCount) {
    return InvalidGenerationSourceError(
      'The query should return a single column instead of $columnCount.',
      todo: 'Either change the target type or alter your query.',
      element: _queryElement,
    );
  }

  InvalidGenerationSourceError columnNotFound(Field field) {
    return _newError(
      'The query should return a column named `${field.columnName}`',
      'remove the field',
      field.fieldElement,
    );
  }

  InvalidGenerationSourceError nullableMismatch(Field field) {
    return _newError(
      'The query returns `null` for `${field.columnName}` but the type of the field is not nullable',
      'make the field nullable',
      field.fieldElement,
    );
  }

  InvalidGenerationSourceError nullableMismatch2(Field field) {
    return _newError(
      'The query could return `null` for `${field.columnName}` but the type of the field is not nullable',
      'make the field nullable',
      field.fieldElement,
    );
  }

  InvalidGenerationSourceError typeMismatch(Field field, BasicType parserType) {
    return _newError(
      'The query returns a column of type ${_getSqlType(parserType)} '
          'for `${field.columnName}` but the type of the field is ${field.sqlType}',
      'change the field type',
      field.fieldElement,
    );
  }

  InvalidGenerationSourceError returnTypeMismatch(
      DartType returnType, BasicType parserType) {
    return InvalidGenerationSourceError(
      'The query returns a column of type ${_getSqlType(parserType)} '
      'but the method return type is $returnType',
      todo: 'Either change the target type or alter your query.',
      element: _queryElement,
    );
  }

  InvalidGenerationSourceError _newError(
      String message, String fieldAlteration, FieldElement field) {
    final buffer = StringBuffer(message);
    try {
      final span = spanForElement(field);
      buffer
        ..writeln()
        ..writeln(span.start.toolString)
        ..write(span.highlight());
    } catch (_) {
      // Source for `element` wasn't found, it must be in a summary with no
      // associated source. We can still give the name.
      buffer..writeln()..writeln('Cause: $field');
    }

    return InvalidGenerationSourceError(buffer.toString(),
        todo: 'Either $fieldAlteration or alter your query.',
        element: _queryElement);
  }

  static String _getSqlType(BasicType parserType) {
    switch (parserType) {
      case BasicType.nullType:
        return 'NULL';
      case BasicType.int:
        return 'INTEGER';
      case BasicType.real:
        return 'REAL';
      case BasicType.text:
        return 'TEXT';
      case BasicType.blob:
        return 'BLOB';
    }
    throw ArgumentError('_getSqlType was called on an invalid value:'
        '`$parserType`. This is a bug in floor.');
  }
}
