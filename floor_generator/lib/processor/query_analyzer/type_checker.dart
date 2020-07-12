import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/error/type_checker_error.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:floor_generator/misc/type_utils.dart';

//TODO TypeConverters!!

void assertMatchingTypes(List<Field> fields,
    List<ColumnWithType> resolvedColumns, Element queryElement) {
  final converted = resolvedColumns
      .map((e) => SqlResultColumn.fromColumnWithType(e))
      .toList(growable: false);
  assertMatchingReturnTypes(fields, converted, queryElement);
}

void assertMatchingReturnTypes(List<Field> fields,
    List<SqlResultColumn> resolvedColumns, Element queryElement) {
  final error = TypeCheckerError(queryElement);

  if (fields.length != resolvedColumns.length) {
    throw error.columnCountMismatch(fields.length, resolvedColumns.length);
  }

  for (int i = 0; i < fields.length; ++i) {
    final column = resolvedColumns.firstWhere(
        (col) => col.name == fields[i].columnName,
        orElse: () => throw error.columnNotFound(fields[i]));

    if (!column.isResolved) {
      warn(queryElement,
          'the resulting type of column `${column.name}` could not be resolved, skipping.');
      continue;
    }

    //final resolvedColumnType = column.sqltype;

    //be strict here, but could be too strict.
    if (column.sqlType == BasicType.nullType && !fields[i].isNullable) {
      throw error.nullableMismatch(fields[i]);
    }

    if (column.sqlType != BasicType.nullType) {
      if (sqlToBasicType[fields[i].sqlType] != column.sqlType) {
        throw error.typeMismatch(fields[i], column.sqlType);
      }
      if (column.isNullable && !fields[i].isNullable) {
        throw error.nullableMismatch2(fields[i]);
      }
    }
  }
}

void assertMatchingSingleReturnType(DartType primitiveType,
    List<SqlResultColumn> resolvedColumns, Element queryElement) {
  if (resolvedColumns.length != 1) {
    throw TypeCheckerError(queryElement)
        .columnCountShouldBeOne(resolvedColumns.length);
  }

  final column = resolvedColumns.first;

  if (!column.isResolved) {
    warn(queryElement,
        'the resulting type of column `${column.name}` could not be resolved, skipping.');
    return;
  }

  // We can assume all primitive return types to be nullable,
  // so omit those checks and directly check the type.

  if (column.sqlType == BasicType.nullType) {
    return; // if the column returns null, it will match all types.
  }

  if (_getSqlParserType(primitiveType) != column.sqlType) {
    throw TypeCheckerError(queryElement)
        .returnTypeMismatch(primitiveType, column.sqlType);
  }
}

void assertMatchingVoidReturn(
    List<SqlResultColumn> resolvedColumns, Element queryElement) {
  if (resolvedColumns.isEmpty) {
    return;
  }
  warn(queryElement, 'query returns non-empty result which will be ignored');
}

@nonNull
BasicType _getSqlParserType(DartType type) {
  if (type.isDartCoreInt) {
    return BasicType.int;
  } else if (type.isDartCoreString) {
    return BasicType.text;
  } else if (type.isDartCoreBool) {
    return BasicType.int;
  } else if (type.isDartCoreDouble) {
    return BasicType.real;
  } else if (type.isUint8List) {
    return BasicType.blob;
  } else {
    throw ArgumentError('_getSqlParserType was called on an invalid value:'
        '`$type`. This is a bug in floor.');
  }
}

void warn(Element element, String message) {
  final buffer = StringBuffer('WARNING: $message');
  try {
    final span = spanForElement(element);
    buffer
      ..writeln()
      ..writeln(span.start.toolString)
      ..write(span.highlight());
  } catch (_) {
    // Source for `element` wasn't found, it must be in a summary with no
    // associated source. We can still give the name.
    buffer..writeln()..writeln('Cause: $element');
  }
  print(buffer.toString());
}
